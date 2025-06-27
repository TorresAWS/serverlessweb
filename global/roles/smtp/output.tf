output "instructions" {
  sensitive = true
  value     =<<EOT
  username: ${aws_iam_access_key.smtp_user.id}
  password: ${aws_iam_access_key.smtp_user.ses_smtp_password_v4}
  Port: 587 
  Connection security: STARTTLS 
  Authentication method: Normal password 
  server:email-smtp.us-east-1.amazonaws.com
EOT
}
