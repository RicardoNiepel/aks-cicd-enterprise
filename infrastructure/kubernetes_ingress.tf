resource "azurerm_public_ip" "nginx_ingress_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.aksrg.location
  name                = local.prefix_kebab
  resource_group_name = azurerm_kubernetes_cluster.akstf.node_resource_group
  sku                 = "Standard"
  domain_name_label   = "${local.prefix_kebab}-${local.hash_suffix}"
}

resource "helm_release" "nginx_ingress" {
  name      = "ingress-nginx"
  chart     = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace = kubernetes_namespace.nginx_ingress.metadata[0].name

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = azurerm_public_ip.nginx_ingress_pip.resource_group_name
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.nginx_ingress_pip.ip_address
  }

  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "$(POD_NAMESPACE)/${kubernetes_secret.nginx_ingress_default_ssl_certificate.metadata[0].name}"
  }

  depends_on = [kubernetes_secret.nginx_ingress_default_ssl_certificate]
}

resource "kubernetes_secret" "nginx_ingress_default_ssl_certificate" {

  metadata {
    name      = "default-ssl-certificate"
    namespace = kubernetes_namespace.nginx_ingress.metadata[0].name
  }

  data = {
    // Decode to avoid double encoding as the 'kubernetes_secret' provider automatically encodes in base64
    "tls.crt" = base64decode(var.tls_cert_base64)
    "tls.key" = base64decode(var.tls_key_base64)
  }

  type = "Opaque"
}

output "AKS_INGRESS_FQDN" {
  value = azurerm_public_ip.nginx_ingress_pip.fqdn
}