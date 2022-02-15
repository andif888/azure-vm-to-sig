# source managed disk
variable "azure_source_managed_disk_name" {
  type    = string
  default = ""
}
variable "azure_source_managed_disk_resource_group_name" {
  type    = string
  default = ""
}

# temporary resources

variable "azure_location" {
  type        = string
  default     = ""
  description = "The Azure Region in which the resources in this example should exist"
}
variable "azure_temp_resource_group_name" {
  type        = string
  description = "The Azure Resource Group"
  default     = ""
}
variable "azure_temp_virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}
variable "azure_temp_vm_name" {
  type    = string
  default = ""
}
variable "azure_temp_vm_size" {
  type    = string
  default = ""
}
variable "azure_temp_managed_disk_name" {
  type    = string
  default = ""
}

variable "azure_temp_managed_disk_hyper_v_generation" {
  type    = string
  default = ""
}

variable "azure_temp_image_name" {
  type    = string
  default = ""
}

# Azure compute gallery

variable "azure_sig_resource_group_name" {
  type    = string
  default = ""
}
variable "azure_sig_name" {
  type    = string
  default = ""
}
variable "azure_sig_image_definition_name" {
  type    = string
  default = ""
}
