resource "azurerm_kubernetes_cluster" "akstf" {
  name                = "${local.prefix_flat}-aks-${local.hash_suffix}"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = local.prefix_kebab
  kubernetes_version  = var.aks_kubernetes_version_prefix
  node_resource_group = "${azurerm_resource_group.aksrg.name}_nodes_${azurerm_resource_group.aksrg.location}"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = var.vm_size
    os_disk_size_gb = 120
    max_pods        = 30
    vnet_subnet_id  = azurerm_subnet.aksnet.id
    node_labels = {
      pool        = "default"
      environment = var.environment_name
    }
    tags = {
      pool        = "default"
      environment = var.environment_name
    }
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id = data.azurerm_client_config.current.tenant_id
  }

  network_profile {
    network_plugin    = "azure"
    service_cidr      = "10.2.0.0/24"
    dns_service_ip    = "10.2.0.10"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.akslogs.id
  }

  tags = {
    environment = var.environment_name
    network     = "azurecni"
    rbac        = "true"
    policy      = "calico"
  }

  depends_on = [azurerm_subnet.aksnet]
}

# merge kubeconfig from the cluster
resource "null_resource" "get-credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.aksrg.name} --name ${azurerm_kubernetes_cluster.akstf.name}"
  }
  depends_on = [azurerm_kubernetes_cluster.akstf]
}

output "KUBE_NAME" {
  value = var.environment_name
}

output "KUBE_GROUP" {
  value = azurerm_resource_group.aksrg.name
}

output "NODE_GROUP" {
  value = azurerm_kubernetes_cluster.akstf.node_resource_group
}

output "ID" {
  value = azurerm_kubernetes_cluster.akstf.id
}

output "HOST" {
  value = one(azurerm_kubernetes_cluster.akstf.kube_config).host
  sensitive = true
}

output "SERVICE_PRINCIPAL_ID" {
  value = one(azurerm_kubernetes_cluster.akstf.identity).principal_id
}
