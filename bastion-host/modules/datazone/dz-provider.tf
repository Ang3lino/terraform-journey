

terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = local.region
}

# Configure the AWS CC Provider
provider "awscc" {
  region = local.region
}
