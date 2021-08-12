###############################
##########  USERS  ############
###############################

resource "aws_iam_user" "users" {
  for_each = toset([for user in local.users : user.name])
  name     = each.value
  tags = {
    terraform = true
  }
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
#########  POLICIES  ##########
###############################
resource "aws_iam_user_policy" "assume_role" {
  # https://github.com/hashicorp/terraform/issues/17179
  for_each   = { for item_key, item in (flatten([for user in local.users : [for role in user.roles : {user = user.name, role = role.name, resources = join(", ", formatlist("\"arn:aws:iam::%s:role/${role.name}\"",role.account))} ]])) : "${item.user}Has${item.role}" => item}
  name       = "${each.value.user}-${each.value.role}AssumeRole"
  depends_on = [aws_iam_user.users]
  user       = each.value.user
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [${each.value.resources}]
    }
  ]  
}
EOF
}
