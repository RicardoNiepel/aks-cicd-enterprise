resource "kubernetes_namespace_v1" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

moved {
  from = kubernetes_namespace.nginx_ingress
  to   = kubernetes_namespace_v1.nginx_ingress
}