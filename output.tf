output "users_password" {
  value = aws_iam_user_login_profile.users_password
}

output "users_access_keys" {
  description = "Fingermark Users Access Keys"
  value = aws_iam_access_key.users_access_keys
  sensitive = true
}