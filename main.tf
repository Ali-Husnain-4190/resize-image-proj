resource "aws_s3_bucket" "s3_bucket_1" {
  bucket = var.first_bucket

  tags = {
    Name = var.first_bucket
    # Environment = """
  }
}
resource "aws_s3_bucket" "s3_bucket_2" {
  bucket = var.second_bucket
  tags = {
    Name = var.second_bucket
  }
}
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_roles"
  path        = "/"
  description = "AWS IAM Policy for managing AWS Lambda role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      },
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "*"
      },
      {  "Sid" : "VisualEditor1",
            "Effect" : "Allow",
            "Action" : "sns:Publish",
            "Resource" : "arn:aws:sns:us-east-1:028326424923:user-updates-topic"
          }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name               = "image_resize_lambda_function"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/file/"
  output_path = "${path.module}/file/resize.zip"
}
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "resize-image"
  role          = aws_iam_role.lambda_role.arn
  handler       = "resize-image.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
  layers  = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p310-Pillow:6"]
  timeout = 250

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

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "alihusnain4190@gmail.com"
}
output "sns_arn" {
  value = aws_sns_topic.user_updates.arn
}
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.test_lambda.function_name

  destination_config {
    # on_failure {
    #   destination = aws_sqs_queue.example.arn
    # }

    on_success {
      destination = aws_sns_topic.user_updates.arn
    }
  }
}