# Launch Template for EC2
resource "aws_launch_template" "as_template" {
  name_prefix            = "tf-template-"
  image_id               = var.ami_free
  instance_type          = var.ec2_type
  vpc_security_group_ids = var.sec_group_ids
  user_data = base64encode(<<-EOF
      #!/bin/bash
      sudo dnf update
      sudo dnf install postgresql15 -y
      EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance using the Key Pair
resource "aws_instance" "ec2_instance" {
#   subnet_id = data.aws_subnets.default.ids[0]
  subnet_id = var.subnet_id
  key_name  = aws_key_pair.generated_key_pair.key_name # Reference the AWS Key Pair
  launch_template {
    id      = aws_launch_template.as_template.id
    version = "$Latest"
  }
  tags = {
    Name = "EC2InstanceFromLaunchTemplate"
  }
}

# Generate an SSH Key Pair
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "my_aws_key.pem"
  file_permission = "0400" # Set permission to 400 for security
}

# Create an AWS Key Pair using the public key
resource "aws_key_pair" "generated_key_pair" {
  key_name   = "my_generated_key"
  public_key = tls_private_key.generated.public_key_openssh
}
