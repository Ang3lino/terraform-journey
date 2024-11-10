provider "aws" {
  region = "us-east-1"
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
}

# Launch Template for EC2
resource "aws_launch_template" "as_template" {
  name_prefix            = "tf-example-"
  image_id               = var.ami_free
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.instance.id]
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
