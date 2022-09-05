output "cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}