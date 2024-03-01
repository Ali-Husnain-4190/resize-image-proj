terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  # region     = "us-east-1"
  # secret_key = ""
  # access_key = ""

}


#  set AWS_ACCESS_KEY_ID=""
#  set AWS_SECRET_ACCESS_KEY=""
#  set AWS_DEFAULT_REGION=""
# $ terraform plan