terraform {
  required_version = ">= 0.13.2"

  # 1. 统一声明 Provider 来源与版本
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=1.11.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=1.2.2"
    }
    null = {
      source  = "hashicorp/null"
    }
    random = {
      source  = "hashicorp/random"
    }
  }

  # 2. 统一声明远端状态后端
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

# ------------------------------------------------------------------
# Provider 实例配置
# ------------------------------------------------------------------

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  load_config_file       = false
  host                   = azurerm_kubernetes_cluster.akstf.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = azurerm_kubernetes_cluster.akstf.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.akstf.kube_admin_config.0.cluster_ca_certificate)
  }
}