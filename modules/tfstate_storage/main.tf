
resource "azurerm_storage_account" "account" {
  # checkov:skip=CKV2_AZURE_21 reason="Don't log blob read requests as no log analytics"
  # checkov:skip=CKV_AZURE_33 reason="Queue service is not used in this storage account"
  # checkov:skip=CKV2_AZURE_1 reason="Allow use of MS managed keys for encryption"
  # checkov:skip=CKV2_AZURE_33 reason="Don't require private endpoint"
  name = var.storage_account_name
  location = var.location
  resource_group_name = var.resource_group_name
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type

  allow_nested_items_to_be_public = false
  public_network_access_enabled = false
  shared_access_key_enabled = false
  min_tls_version          = "TLS1_2"

  blob_properties {
      delete_retention_policy {
        days = 7
      }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "container" {
  # checkov:skip=CKV2_AZURE_21 reason="Don't log blob read requests as no log analytics"
  # checkov:skip=CKV_AZURE_33 reason="Queue service is not used in this storage account"
  # checkov:skip=CKV2_AZURE_1 reason="Allow use of MS managed keys for encryption"
  # checkov:skip=CKV2_AZURE_33 reason="Don't require private endpoint"
  name = var.container_name
  storage_account_name = azurerm_storage_account.account.name
  container_access_type = "private"
}

# resource "azurerm_storage_container" "automatic_container" {
#   # checkov:skip=CKV2_AZURE_21 reason="Don't log blob read requests as no log analytics"
#   # checkov:skip=CKV_AZURE_33 reason="Queue service is not used in this storage account"
#   # checkov:skip=CKV2_AZURE_1 reason="Allow use of MS managed keys for encryption"
#   # checkov:skip=CKV2_AZURE_33 reason="Don't require private endpoint"

#   name = var.automatic_container_name
#   storage_account_name = azurerm_storage_account.account.name
#   container_access_type = "private"
# }
