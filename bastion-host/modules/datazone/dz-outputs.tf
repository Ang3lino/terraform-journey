
# Outputs
output "admin_credentials_secret" {
  value       = aws_secretsmanager_secret.admin_secret.id
  description = "Secret ARN for admin credentials"
}

output "producer_credentials_secret" {
  value       = aws_secretsmanager_secret.producer_secret.id
  description = "Secret ARN for producer credentials"
}

output "consumer_credentials_secret" {
  value       = aws_secretsmanager_secret.consumer_secret.id
  description = "Secret ARN for consumer credentials"
}

output "admin_otp" {
  value       = aws_iam_user_login_profile.admin_console.password
  description = "DZ Admin console OTP"
  sensitive   = true
 }