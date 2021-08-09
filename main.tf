###############################
##########  USERS  ############
###############################

resource "aws_iam_user" "users" {
  for_each = toset([for user in local.users : user.name])
  name     = each.value
}

resource "aws_iam_user_login_profile" "users_password" {
  depends_on = [aws_iam_user.users]
  for_each   = toset([for user in local.users : user.name])
  user       = each.value
  pgp_key    = var.keybase
  lifecycle {
    ignore_changes = [password_length, password_reset_required, pgp_key]
  }
}

resource "aws_iam_access_key" "users_access_keys" {
  for_each   = toset([for user in local.users : user.name])
  user       = each.value
  pgp_key    = var.keybase
  depends_on = [aws_iam_user.users]
}

###############################
##########  GROUPS  ###########
###############################

resource "aws_iam_group" "general" {
  name = "general"
}

resource "aws_iam_group_membership" "general" {
  name  = "GeneralGroupMembership"
  users = toset([for user in local.users : user.name])
  group = aws_iam_group.general.name
}

resource "aws_iam_group_policy" "general_group_policy" {
  name  = "GeneralGroupPolicy"
  group = aws_iam_group.general.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:ChangePassword"
        ],
        "Resource" : [
          "arn:aws:iam::*:user/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:GetAccountPasswordPolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}



###############################
##########  ROLES  ############
###############################
resource "aws_iam_user_policy" "admin_access" {
  for_each   = { for item_key, item in(flatten([for user_key, user in local.users : [for role_key, role in user.roles : [for account_key, account in role.account : { user = user.name, role = role.name, account = account }]]])) : item_key => item }
  name       = "${each.value.role}AssumeRoleOn${each.value.account}"
  depends_on = [aws_iam_user.users]
  user       = each.value.user
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${each.value.account}:role/${each.value.role}"
    }
  ]  
}
EOF
}
