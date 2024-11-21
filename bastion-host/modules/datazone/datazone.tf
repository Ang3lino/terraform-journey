
provider "aws" {
  region = "us-east-1"
}

# IAM Role for DataZone
resource "aws_iam_role" "datazone_role" {
  name               = "datazone_domain_creator_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "datazone.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

# Policy for DataZone Domain Management
resource "aws_iam_policy" "datazone_policy" {
  name        = "datazone_domain_permissions"
  description = "Policy to allow creating and managing DataZone domains"
  policy      = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect   : "Allow",
        Action   : [
          "datazone:CreateDomain",
          "datazone:DeleteDomain",
          "datazone:GetDomain"
        ],
        Resource : "*"
      }
    ]
  })
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "datazone_role_attachment" {
  role       = aws_iam_role.datazone_role.name
  policy_arn = aws_iam_policy.datazone_policy.arn
}

# Create DataZone Domain using IAM Role
resource "null_resource" "datazone_domain" {
  provisioner "local-exec" {
    command = <<EOT
      aws datazone create-domain \
        --name "my-datazone-domain" \
        --description "My DataZone domain for managing data assets" \
        --role-arn "${aws_iam_role.datazone_role.arn}" \
        --output json > datazone_domain_output.json
    EOT
  }
}

# Output Role ARN for external usage
output "datazone_role_arn" {
  value = aws_iam_role.datazone_role.arn
}

# Instruction for Deletion
output "delete_instructions" {
  value = <<EOT
Run the following commands manually to delete the domain:

DOMAIN_ID=$(jq -r '.domainId' datazone_domain_output.json)
aws datazone delete-domain --domain-id "$DOMAIN_ID" --role-arn "${aws_iam_role.datazone_role.arn}"
EOT
  description = "Instructions to delete the DataZone domain manually"
}
