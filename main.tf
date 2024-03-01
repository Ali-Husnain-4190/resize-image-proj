resource "aws_s3_bucket" "s3_bucket_1" {
  bucket = "my-resize-1"

  tags = {
    Name = "my-resize-1"
    # Environment = """
  }
}
resource "aws_s3_bucket" "s3_bucket_2" {
  bucket = "my-resize-2"
  tags = {
    Name = "my-resize-2"
  }
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/file/"
  output_path = "${path.module}/file/resize.zip"
}
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      =  data.archive_file.lambda.output_path
  function_name = "resize-image"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       =  "resize-image.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
  layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p310-Pillow:6"]


}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.s3_bucket_1.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]

  }
}
resource "aws_lambda_permission" "aws_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.s3_bucket_1.id}"
}
