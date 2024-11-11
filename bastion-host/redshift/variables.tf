

variable "redshift_port" { default = 5439 }
variable "node_type" { default = "dc2.large" }
variable "number_of_nodes" { default = 1 }
variable "db_name" { default = "dev" }
variable "skip_final_snapshot" { default = true }

# required
variable "bastion_sg" { }
variable "vpc_id" { }

variable "username" { }
variable "password" { }