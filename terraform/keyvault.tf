resource "azurerm_key_vault" "akskv" {
  name                        = "${local.prefix_kebab}-kv-${local.hash_suffix}"
  location                    = azurerm_resource_group.aksrg.location
  resource_group_name         = azurerm_resource_group.aksrg.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = var.environment_name
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault_secret.html
# resource "azurerm_key_vault_secret" "appinsights_secret" {
#   name         = "appinsights-key"
#   value        = azurerm_application_insights.aksainsights.instrumentation_key
#   key_vault_id = azurerm_key_vault.aksvault.id
  
#   tags = {
#     environment = var.environment_name
#   }
# }
