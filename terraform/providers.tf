provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# AWS region aliases for multi-region support.
# Add additional aliases here if your chain uses other regions.
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "us-west-2"
  region  = "us-west-2"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "eu-west-1"
  region  = "eu-west-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "eu-central-1"
  region  = "eu-central-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "ap-southeast-1"
  region  = "ap-southeast-1"
  profile = var.aws_profile
}
