terraform {
  required_version = ">= 1.17.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
provider "kubernetes" {
  host                   = one(azurerm_kubernetes_cluster.akstf.kube_admin_config).host
  client_certificate     = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).client_certificate)
  client_key             = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).client_key)
  cluster_ca_certificate = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = one(azurerm_kubernetes_cluster.akstf.kube_admin_config).host
    client_certificate     = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).client_certificate)
    client_key             = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).client_key)
    cluster_ca_certificate = base64decode(one(azurerm_kubernetes_cluster.akstf.kube_admin_config).cluster_ca_certificate)
  }
}