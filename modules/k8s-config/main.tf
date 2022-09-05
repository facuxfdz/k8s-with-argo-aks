terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.aks_subscription_id
  tenant_id       = var.aks_tenant_id
  client_id       = var.aks_service_principal_app_id
  client_secret   = var.aks_service_principal_client_secret
}

data "azurerm_kubernetes_cluster" "k8s" {
  name = var.cluster_name
  resource_group_name = var.rg_name
  depends_on = [
    var.cluster_id
  ]
}

resource "local_file" "kubeconfig" {
  filename        = "kubeconfig.yaml"
  file_permission = "0600"
  content         = data.azurerm_kubernetes_cluster.k8s.kube_config_raw
}


provider "kubectl" {
  config_path = local_file.kubeconfig.filename
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
  depends_on = [
    var.cluster_id
  ]
  count = length(data.kubectl_file_documents.namespace.documents)
  yaml_body = element(data.kubectl_file_documents.namespace.documents,count.index)
  override_namespace = "argocd"
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
  depends_on = [
    kubectl_manifest.argocd
  ]
  count = length(data.kubectl_file_documents.my-example-app.documents)
  yaml_body = element(data.kubectl_file_documents.my-example-app.documents,count.index)
}