terraform {
  required_version = "1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

backend "s3" {
    bucket = "tfstateslaomiac"  
    key    = "tfstateslaomiac/terraform.tfstate"
    region = "us-east-1"
  }
}