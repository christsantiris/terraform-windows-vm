variable "rgname" {
  type        = string
  description = "resource group name"
  default     = "homelab"
}

variable "rglocation" {
  type        = string
  description = "resource group location"
  default     = "East US"
}

variable "sgname" {
  type        = string
  description = "security group name"
  default     = "homelab-security-group"
}

variable "vnname" {
  type        = string
  description = "virtual network name"
  default     = "homelab-net"
}

variable "niname" {
  type        = string
  description = "network interface name"
  default     = "windowshomelab-nic"
}

variable "snname" {
  type        = string
  description = "subnet name"
  default     = "subnet1"
}

variable "vmname" {
  type        = string
  description = "virtual machine name"
  default     = "chris-winvm"
}

