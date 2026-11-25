include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
  tenant_id       = get_env("ARM_TENANT_ID")
}

terraform {
  source = "../../../modules/github-oidc"
}

inputs = {
  tenant_id       = local.tenant_id
  subscription_id = local.subscription_id

  application_name = "sp-ilicic-github-test-plan"

  github_repository  = "zrre/devops-ilicic"
  github_environment = "test-plan"

  owner_object_ids = [
    "5c27445f-9051-4cbb-864e-b8024dfd232c"
  ]

  reader_scopes = [
    "/subscriptions/${local.subscription_id}/resourceGroups/rg-ilicic-devops-test"
  ]
}