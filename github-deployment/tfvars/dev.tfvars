gh_uai_name                = "svc-gha-tf-id"
github_organization_target = "david-mcgrath-bjss"
container_name             = "tfstate"
#automatic_container_name = "tfstate-aks-automatic"
#storage_account_name = "dmcgightestingdev"
tf_state_rg_name = "rg-tfstate"
identity_rg_name = "rg-identity"
location         = "ukwest"
tags = {
  environment = "dev"
}