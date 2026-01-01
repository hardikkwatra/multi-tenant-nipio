variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "tenants" {
  description = "Tenant definitions (add tenants here)"
  type = map(object({
    instance_type  = string
    volume_size_gb = number
    app_message    = string
  }))
}

