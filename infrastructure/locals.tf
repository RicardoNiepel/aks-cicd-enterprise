data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  prefix_kebab = lower("${replace(var.prefix, "_", "-")}-${terraform.workspace}")
  prefix_snake = lower("${replace(var.prefix, "-", "_")}_${terraform.workspace}")
  prefix_flat  = lower("${replace(replace(var.prefix, "_", ""), "-", "")}${terraform.workspace}")

  // Truncated version to fit e.g. Storage Accounts naming requirements (<=24 chars)).
  prefix_flat_short = "${substr(local.prefix_flat, 0, min(18, length(local.prefix_flat)))}${local.hash_suffix}"
  location          = lower(replace(var.location, " ", ""))
  
  hash_suffix = substr(sha256(azurerm_resource_group.aksrg.id), 0, 5)
}
