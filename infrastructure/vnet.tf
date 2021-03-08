# https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
resource "azurerm_resource_group" "aksrg" {
  name     = "${local.prefix_snake}_rg"
  location = var.location
    
  tags = {
    environment = var.environment_name
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/virtual_network.html
resource "azurerm_virtual_network" "kubevnet" {
  name                = "${local.prefix_kebab}-vnet"
  address_space       = ["10.0.0.0/20"]
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name

  tags = {
    environment = var.environment_name
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/subnet.html
resource "azurerm_subnet" "gwnet" {
  name                      = "gw-1-snet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.1.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "acinet" {
  name                      = "aci-2-snet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.2.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "ingnet" {
  name                      = "ing-4-snet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.4.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "aksnet" {
  name                      = "aks-5-snet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.5.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name

  service_endpoints         = ["Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet" "basnet" {
  name                      = "bas-7-snet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.7.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}

resource "azurerm_public_ip" "bastion_ip" {
  name                         = "bastion-pip"
  location                     = azurerm_kubernetes_cluster.akstf.location
  resource_group_name          = azurerm_kubernetes_cluster.akstf.node_resource_group
  allocation_method            = "Static"
  domain_name_label            = "${local.prefix_kebab}-vnet-ip"

  depends_on = [azurerm_kubernetes_cluster.akstf]
}
