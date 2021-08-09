# AWS USERS

This project is meant to be applied when you need granularity on the user's permissions to different accounts. Users are created on a central account (login account), avoiding managing multiple credentials for every user.

### Requirements
* An AWS account to be used as a logins account and admin access to it
* A target AWS account to test assume role on
* The policies on the target account should be already created. 
* Terraform 0.15 or above
* jq
* A keybase account (optional)

1. Create a file containing the provider's credentials

```
## terraform.tfvars

AWS_ACCESS_KEY = "AAAAAAAAAAAAAAAAA"
AWS_SECRET_KEY = "12345632132454321a5sd32s5d4sd321"
keybase = "keybase:<your_keybase_key>"

```

2. Add users to the locals users variable on the vars.tf file. A user can have diferent roles on different account. See the example.

3. Init the project
```
terraform init
```

4. Create the plan
```
terraform plan -out=plan
```

5. Apply the changes
```
terraform apply plan
```
6. Get the credentials
```
./get-credentials.sh <user_name>

```
The credentials will be stored on the credentials folder.