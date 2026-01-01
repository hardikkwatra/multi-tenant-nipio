variable "tenant_name" {
  type = string
}

variable "tenant_index" {
  type        = number
  description = "Unique number per tenant (0-255) used to derive VPC CIDR"
}

variable "instance_type" {
  type = string
}

variable "volume_size_gb" {
  type = number
}

variable "app_message" {
  type        = string
  description = "Text displayed on tenant landing page"
}

