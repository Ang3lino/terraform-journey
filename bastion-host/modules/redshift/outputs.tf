
# ./redshift/outputs.tf

output "redshift_cluster_endpoint" {
  value       = aws_redshift_cluster.this.endpoint
  description = "The endpoint address of the Redshift cluster."
}

output "redshift_cluster_port" {
  value       = aws_redshift_cluster.this.port
  description = "The port the Redshift cluster is listening on."
}

output "redshift_cluster_id" {
  value       = aws_redshift_cluster.this.cluster_identifier
  description = "The Redshift cluster identifier."
}

output "redshift_endpoint" {
  value       = aws_redshift_cluster.this.endpoint
  description = "The Redshift cluster identifier."
}