
module "redshift_cluster" {
  source     = "./modules/redshift"
  bastion_sg = aws_security_group.instance
  vpc_id     = data.aws_vpc.default.id
  username   = "awsuser"
  password   = var.redshift_password
  iam_roles  = [aws_iam_role.redshift_admin_role.arn] # Attach IAM Role here
}

module "ec2_instance" {
  source        = "./modules/ec2"
  subnet_id     = data.aws_subnets.default.ids[0]
  sec_group_ids = [aws_security_group.instance.id]
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "tf-angelttv-datalake"
  force_destroy = true # This will delete all objects in the bucket before deletion
}

# Local provisioner to upload files to the bucket
resource "null_resource" "upload_files" {
  depends_on = [aws_s3_bucket.bucket]

  provisioner "local-exec" {
    command = <<EOT
      aws s3 sync ./tf-angelttv-datalake/ s3://${aws_s3_bucket.bucket.bucket} --delete
    EOT
  }
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
