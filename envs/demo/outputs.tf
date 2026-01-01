output "tenant_urls" {
  value = {
    for k, m in module.tenant : k => {
      public_ip = m.public_ip
      url       = m.url
      vpc_id    = m.vpc_id
      instance  = m.instance_id
      volume_id = m.volume_id
    }
  }
}

