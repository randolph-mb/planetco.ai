provider "aws" {
  region  = "eu-central-1"
  profile = "planetco-website"

  default_tags {
    tags = {
      Project   = "planetco.ai"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "planetco-website"

  default_tags {
    tags = {
      Project   = "planetco.ai"
      ManagedBy = "terraform"
    }
  }
}
