##############
## PROVIDER ##
##############

variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "ap-southeast-2"
}

###############################
##########  USERS  ############
###############################

locals {
  users = [
    { 
      "name": "test.admin",
      "roles": [
        {
          "name": "RoleName",
          "account": ["12345678012", "210987654321"]
        }
      ]
    },
    { 
      "name": "test.dev",
      "roles": [
        {
          "name": "DevAccess",
          "account": ["555566664421", "111111111111"]
        }
      ]
    },        
  ]
}

variable "keybase" {
}


