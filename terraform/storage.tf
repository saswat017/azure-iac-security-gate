resource "azurerm_storage_account" "sa" {
  name                     = "stiacgatewind001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = true
  enable_https_traffic_only       = false
  min_tls_version                 = "TLS1_0"
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "data" {
  name                  = "public-data"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "blob"
}