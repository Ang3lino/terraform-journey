

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

variable "dz_admin_access_key" {
  default = "your_key"
}

variable "dz_admin_secret_key" {
  default = "your_key"
}

provider "aws" {
  region = local.region
  # Use access key and secret for the DZ admin (replace with appropriate variables or environment variables)
  access_key = var.dz_admin_access_key
  secret_key = var.dz_admin_secret_key
}

# Configure the AWS CC Provider
provider "awscc" {
  region = local.region
}

