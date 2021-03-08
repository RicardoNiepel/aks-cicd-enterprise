# Configure the Azure Provider
# https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/terraform/terraform-create-k8s-cluster-with-tf-and-aks.md
provider "azurerm" {
  version = "=2.33.0"
  features {}
}

provider "kubernetes" {
  version                = "=1.11.3"
  load_config_file       = false
  host                   = azurerm_kubernetes_cluster.akstf.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  version = "=1.2.2"

  kubernetes {
    load_config_file       = false
    host                   = azurerm_kubernetes_cluster.akstf.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.cluster_ca_certificate)
  }
}