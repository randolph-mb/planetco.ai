terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  backend "s3" {
    bucket       = "planetco-tfstate-862910165525"
    key          = "planetco-ai/website.tfstate"
    region       = "eu-central-1"
    profile      = "planetco-website"
    encrypt      = true
    use_lockfile = true
  }
}
