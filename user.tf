###############################
##########  USERS  ############
###############################

locals {
  users = [
    {
      "name" : "test.admin",
      "roles" : [
        {
          "name" : "RoleName",
          "account" : ["12345678012", "210987654321"]
        }
      ]
    },
    {
      "name" : "test.dev",
      "roles" : [
        {
          "name" : "DevAccess",
          "account" : ["555566664421", "111111111111"]
        }
      ]
    },
  ]
}
