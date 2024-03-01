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
  # secret_key = "AKIAVA3L5BES3NPK225Z"
  # access_key = "uH+XIMxQWtO13poeKhuneBzzGkhFXewqTD6QTz1u"

}


#  set AWS_ACCESS_KEY_ID="AKIATCKAP56CMEYQN2B5"
#  set AWS_SECRET_ACCESS_KEY="uH+oMm3kg6lldjwAyYdpwyb60cEcEvtgT05NG2A67Wx"
#  set AWS_DEFAULT_REGION="us-east-1"
# $ terraform plan