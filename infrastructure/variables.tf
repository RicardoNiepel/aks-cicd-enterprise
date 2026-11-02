variable "prefix" {
  type        = string
  description = "Injected via tf.ps1. Resource prefix."
}

variable "location" {
  type        = string
  description = "Injected via tf.ps1. Resource location."
}

variable "aks_kubernetes_version_prefix" {
  type        = string
  default     = null
  description = "Optional Kubernetes version (MAJOR.MINOR); unset lets AKS select its recommended version when creating a cluster."
}

variable "environment_name" {
  type = string
  # default = "NAME"
  description = "default tag applied to all resources"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "tls_cert_base64" {
  type        = string
  default     = ""
  description = "Default certificate for ingress controller."
}

variable "tls_key_base64" {
  type        = string
  default     = ""
  description = "Default certificate for ingress controller."
}
