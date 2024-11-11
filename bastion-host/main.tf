provider "aws" {
  region = "us-east-1"
}

module "redshift_cluster" {
  source     = "./redshift"
  bastion_sg = aws_security_group.instance
  vpc_id     = data.aws_vpc.default.id
  username   = "awsuser"
  password   = var.redshift_password
}

# Security Group allowing SSH access
resource "aws_security_group" "instance" {
  name = "bh-sg"
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # this helps ec2 to update with user data instructions
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template for EC2
resource "aws_launch_template" "as_template" {
  name_prefix            = "tf-example-"
  image_id               = var.ami_free
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = base64encode(<<-EOF
      #!/bin/bash
      sudo dnf update
      sudo dnf install postgresql15
      EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

# Generate an SSH Key Pair
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

# Save the Private Key locally as PEM file
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "my_aws_key.pem"
}

# Create an AWS Key Pair using the public key
resource "aws_key_pair" "generated_key_pair" {
  key_name   = "my_generated_key"
  public_key = tls_private_key.generated.public_key_openssh
}

# EC2 Instance using the Key Pair
resource "aws_instance" "ec2_instance" {
  subnet_id = data.aws_subnets.default.ids[0]
  key_name  = aws_key_pair.generated_key_pair.key_name # Reference the AWS Key Pair

  launch_template {
    id      = aws_launch_template.as_template.id
    version = "$Latest"
  }

  tags = {
    Name = "EC2InstanceFromLaunchTemplate"
  }
}
