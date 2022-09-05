variable "aks_subscription_id" {
  type = string
}

variable "aks_tenant_id" {
  type = string
}

variable "aks_service_principal_app_id" {
    type = string
}

variable "aks_service_principal_client_secret" {
  type = string
}

variable "resource_group_name_prefix" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "agent_count" {
  type = number
}


