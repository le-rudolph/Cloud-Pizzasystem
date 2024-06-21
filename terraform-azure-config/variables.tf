variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."
  default     = "germanywestcentral"
}

variable "resource_group_name_prefix" {
  type        = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  default     = "rg"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "pizza"
}

variable "control_node_setup_script" {
  type        = string
  description = "Path to the setup file to use on the vm."
  default     = "./scripts/setup_control_node.sh"
}

variable "worker_node_setup_script" {
  type        = string
  description = "Path to the setup file to use on the vm."
  default     = "./scripts/setup_worker_node.sh"
}
