# https://www.terraform.io/docs/providers/azurerm/r/container_registry.html

resource "azurerm_container_registry" "aksacr" {
  name                     = "${local.prefix_flat}acr${local.hash_suffix}"
  resource_group_name      = azurerm_resource_group.aksrg.name
  location                 = azurerm_resource_group.aksrg.location
  sku                      = "Premium"
  admin_enabled            = true

  tags = {
    environment = var.environment_name
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.aksacr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.akstf.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}


output "REGISTRY_URL" {
  value = azurerm_container_registry.aksacr.login_server
}

output "REGISTRY_NAME" {
  value = azurerm_container_registry.aksacr.admin_username
}

output "REGISTRY_PASSWORD" {
  value = azurerm_container_registry.aksacr.admin_password
}
