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
  default     = "1.18"
  description = "The Kubernetes Version prefix (MAJOR.MINOR) to be used by the AKS cluster. The BUGFIX version is determined automatically (latest)."
}

variable "environment_name" {
  # default = "NAME"
  description = "default tag applied to all resources"
}

variable "vm_size" {
  default = "Standard_DS2_v2"
}

variable "tls_cert_base64" {
  type = string
  default = ""
  description = "Default certificate for ingress controller."
}

variable "tls_key_base64" {
  type = string
  default = ""
  description = "Default certificate for ingress controller."
}
