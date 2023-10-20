terraform {
  backend "s3" {
    bucket         = "je-test-projects-tf-state"
    key            = "Project_2/import-bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
