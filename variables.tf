variable "resource_group_name_prefix" {
  type = string
  default = "rg"
}

variable "resource_group_location" {
  type = string
  default = "brazilsouth"
}

variable "cluster_name" {
  type = string
  default = "facuxfdz-cluster"
}

variable "dns_prefix" {
  type = string
  default = "facuxfdz"
}

variable "agent_count" {
  type = number
  default = 1
}

# Set these variables in .tfvars
variable "aks_service_principal_app_id" {
  type = string
  default = ""
}

variable "aks_service_principal_client_secret" {
  type = string
  default = ""
}

variable "aks_tenant_id" {
  type = string
  default = ""
}

variable "aks_subscription_id" {
  type = string
  default = ""
}