output "alb_ingress_hostname" {
  description = "ALB Ingress hostname for tc2-web"
  value       = try(kubernetes_ingress_v1.web.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}
