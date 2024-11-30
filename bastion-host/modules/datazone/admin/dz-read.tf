data "aws_datazone_environment_blueprint" "default_data_lake" {
  domain_id = awscc_datazone_domain.example.id
  name      = "DefaultDataLake"
  managed   = true
}

data "aws_datazone_environment_blueprint" "default_dwh" {
  domain_id = awscc_datazone_domain.example.id
  name      = "DefaultDataWarehouse"
  managed   = true
}

output "dz_default_data_lake" {
  value = data.aws_datazone_environment_blueprint.default_data_lake.id
}

output "dz_default_dwh" {
  value = data.aws_datazone_environment_blueprint.default_dwh.id
}