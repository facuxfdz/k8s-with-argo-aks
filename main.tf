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

provider "azurerm" {
  features {}
  subscription_id   = var.aks_subscription_id
  tenant_id         = var.aks_tenant_id
  client_id         = var.aks_service_principal_app_id
  client_secret     = var.aks_service_principal_client_secret
}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_kubernetes_cluster" "k8s" {
    location = azurerm_resource_group.rg.location
    name = var.cluster_name
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix = var.dns_prefix
    tags = {
      "Environment" = "Development"
    }

    default_node_pool {
      name = "agentpool"
      vm_size = "standard_a2_v2"
      node_count = var.agent_count
    }

    linux_profile {
      admin_username = "facuxfdz"

      ssh_key {
        key_data = file(var.ssh_public_key)
      }
    }

    network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "standard"
    }

    service_principal {
      client_id = var.aks_service_principal_app_id
      client_secret = var.aks_service_principal_client_secret
    }
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig.yaml"
  file_permission = "0600"
  content = azurerm_kubernetes_cluster.k8s.kube_config_raw
}


provider "kubectl" {
  config_path = "kubeconfig.yaml"
  load_config_file = true
}

data "kubectl_file_documents" "namespace" {
  content = file("./manifests/argocd/namespace.yaml")
}

data "kubectl_file_documents" "argocd" {
  content = file("./manifests/argocd/install.yaml")
}

data "kubectl_file_documents" "my-example-app" {
  content = file("./manifests/argocd/application.yaml")
}

resource "kubectl_manifest" "namespace" {
  count = length(data.kubectl_file_documents.namespace.documents)
  yaml_body = element(data.kubectl_file_documents.namespace.documents,count.index)
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace
  ]
  count = length(data.kubectl_file_documents.argocd.documents)
  yaml_body = element(data.kubectl_file_documents.argocd.documents,count.index)
  override_namespace = "argocd"
}

resource "kubectl_manifest" "my-example-app" {
  count = length(data.kubectl_file_documents.my-example-app.documents)
  yaml_body = element(data.kubectl_file_documents.my-example-app.documents,count.index)
}