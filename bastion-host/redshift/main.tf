
resource "aws_security_group" "redshift_sg" {
  vpc_id = var.vpc_id
  name   = "redshift-sg"
  ingress {
    from_port   = var.redshift_port
    to_port     = var.redshift_port
    protocol    = "tcp"
    security_groups = [var.bastion_sg.id]
  }
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = var.db_name
  node_type          = var.node_type
  number_of_nodes    = var.number_of_nodes
  master_username    = var.username
  master_password    = var.password
  publicly_accessible = false
  skip_final_snapshot = var.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.redshift_sg.id]
}
