terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.0.0"
    }

    random = {
        source = "hashicorp/random"
        version = "~>3.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

module "k8s" {
  source = "./modules/k8s"

  aks_subscription_id = var.aks_subscription_id
  aks_tenant_id = var.aks_tenant_id
  aks_service_principal_app_id = var.aks_service_principal_app_id
  aks_service_principal_client_secret = var.aks_service_principal_client_secret
  resource_group_name_prefix = var.resource_group_name_prefix
  resource_group_location = var.resource_group_location
  cluster_name = var.cluster_name
  dns_prefix = var.dns_prefix
  agent_count = var.agent_count
}

module "k8s-config" {
  source = "./modules/k8s-config"
  cluster_id = module.k8s.cluster_id
  cluster_name = module.k8s.cluster_name
  rg_name = module.k8s.rg_name
  aks_subscription_id = var.aks_subscription_id
  aks_tenant_id = var.aks_tenant_id
  aks_service_principal_app_id = var.aks_service_principal_app_id
  aks_service_principal_client_secret = var.aks_service_principal_client_secret

}