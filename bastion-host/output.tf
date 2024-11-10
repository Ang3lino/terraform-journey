# Output the ID of the VPC security group used by the instance
output "security_group_id" {
  value       = aws_security_group.instance.id
  description = "The ID of the security group for the EC2 instance"
}

# Output the launch template ID for tracking and reuse
output "launch_template_id" {
  value       = aws_launch_template.as_template.id
  description = "The ID of the launch template used to create the EC2 instance"
}

# Output the EC2 instance ID
output "instance_id" {
  value       = aws_instance.ec2_instance.id
  description = "The ID of the EC2 instance"
}

# Output the public IP address of the EC2 instance for SSH access
output "instance_public_ip" {
  value       = aws_instance.ec2_instance.public_ip
  description = "The public IP address of the EC2 instance"
}

# Output the private IP address of the EC2 instance (useful for VPC configurations)
output "instance_private_ip" {
  value       = aws_instance.ec2_instance.private_ip
  description = "The private IP address of the EC2 instance"
}

# Output the SSH key file name for easy reference
output "ssh_key_file" {
  value       = local_file.private_key_pem.filename
  description = "The name of the PEM file used for SSH access"
}

# Output the AWS Key Pair name for tracking in the AWS console
output "key_pair_name" {
  value       = aws_key_pair.generated_key_pair.key_name
  description = "The AWS Key Pair name associated with the EC2 instance"
}

# New output for SSH command
output "ssh_login_command" {
  value       = "ssh -i ${local_file.private_key_pem.filename} ec2-user@${aws_instance.ec2_instance.public_ip}"
  description = "SSH login command to access the EC2 instance"
}   