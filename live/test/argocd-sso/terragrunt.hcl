include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = [
    "../aks"
  ]
}

terraform {
  source = "../../../modules/argocd-sso"
}

inputs = {
  tenant_id = "b2748d0a-856e-4184-bda8-831f9ffa8a48"

  application_name = "argocd-ilicic-test"

  argocd_url = "https://argo.zrre.net"

  oidc_issuer_url = "https://westeurope.oic.prod-aks.azure.com/b2748d0a-856e-4184-bda8-831f9ffa8a48/fac4c309-64a9-4ca3-bdfa-814f71996e61/"

  admin_user_object_id = "5c27445f-9051-4cbb-864e-b8024dfd232c"

  tester_user_object_id = "05e4fa9c-bb17-442e-825e-086a64c7e717"

  namespace            = "argocd"
  service_account_name = "argocd-server"
}