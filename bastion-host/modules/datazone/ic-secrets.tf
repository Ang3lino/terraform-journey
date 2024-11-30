

# Almacenar las credenciales en Secrets Manager
resource "aws_secretsmanager_secret" "admin_secret" {
  name                    = "datazone-admin-credentials"
  description             = "AWS IAM credentials for DataZone Admin"
  recovery_window_in_days = 0 # forces automatic deletion
}

resource "aws_secretsmanager_secret_version" "admin_secret_version" {
  secret_id = aws_secretsmanager_secret.admin_secret.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.admin.id
    secret_access_key = aws_iam_access_key.admin.secret
  })
}

resource "aws_secretsmanager_secret" "producer_secret" {
  name                    = "datazone-producer-credentials"
  description             = "AWS IAM credentials for DataZone Producer"
  recovery_window_in_days = 0 # forces automatic deletion
}

resource "aws_secretsmanager_secret_version" "producer_secret_version" {
  secret_id = aws_secretsmanager_secret.producer_secret.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.producer.id
    secret_access_key = aws_iam_access_key.producer.secret
  })
}

resource "aws_secretsmanager_secret" "consumer_secret" {
  name                    = "datazone-consumer-credentials"
  description             = "AWS IAM credentials for DataZone Consumer"
  recovery_window_in_days = 0 # forces automatic deletion
}

resource "aws_secretsmanager_secret_version" "consumer_secret_version" {
  secret_id = aws_secretsmanager_secret.consumer_secret.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.consumer.id
    secret_access_key = aws_iam_access_key.consumer.secret
  })
}

