
variable "redshift_password" {
  sensitive = true
}

variable "source_account_id" {
  type        = string
  description = "Source AWS account id"
  sensitive   = true
}


# Variables necesarias
variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}