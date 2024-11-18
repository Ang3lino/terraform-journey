# Output the ID of the VPC security group used by the instance
output "security_group_id" {
  value       = aws_security_group.instance.id
  description = "The ID of the security group for the EC2 instance"
}


# # Output the public IP address of the EC2 instance for SSH access
# output "instance_public_ip" {
#   value       = module.ec2_instance.public_ip
#   description = "The public IP address of the EC2 instance"
# }

# # Output the private IP address of the EC2 instance (useful for VPC configurations)
# output "instance_private_ip" {
#   value       = aws_instance.ec2_instance.private_ip
#   description = "The private IP address of the EC2 instance"
# }


# Redshift module outputs
output "redshift_endpoint" {
  value       = module.redshift_cluster.redshift_cluster_endpoint
  description = "The endpoint address of the Redshift cluster from the module."
}

output "redshift_port" {
  value       = module.redshift_cluster.redshift_cluster_port
  description = "The port of the Redshift cluster from the module."
}

output "redshift_cluster_id" {
  value       = module.redshift_cluster.redshift_cluster_id
  description = "The cluster ID of the Redshift cluster from the module."
}

output "ec2_ssh_login_command" {
  value       = module.ec2_instance.ssh_login_command
  description = "SSH login command to access the EC2 instance"
}

# psql -h $RS_ENDPOINT -U awsuser -d dev -p 5439
output "rs_psql_cmd" {
  value       = replace("psql -h ${module.redshift_cluster.redshift_endpoint} -U awsuser -d dev -p ${module.redshift_cluster.redshift_cluster_port}", ":${module.redshift_cluster.redshift_cluster_port}", "")
  description = "SSH login command to access the EC2 instance"
}

# output "redshift_endpoint" {
#   value       = module.redshift_cluster.endpoint
#   description = "The cluster ID of the Redshift cluster from the module."
# }