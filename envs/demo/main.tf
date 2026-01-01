locals {
  tenant_keys_sorted = sort(keys(var.tenants))

  tenant_index_map = { for idx, k in local.tenant_keys_sorted : k => idx + 10 }
}

module "tenant" {
  for_each = var.tenants
  source   = "../../modules/tenant_aws_nip"

  tenant_name  = each.key
  tenant_index = local.tenant_index_map[each.key]

  instance_type  = each.value.instance_type
  volume_size_gb = each.value.volume_size_gb
  app_message    = each.value.app_message
}

