output "public_ip"  { value = aws_instance.this.public_ip }
output "url"        { value = local.url }

output "vpc_id"     { value = aws_vpc.this.id }
output "vpc_cidr"   { value = aws_vpc.this.cidr_block }

output "instance_id" { value = aws_instance.this.id }
output "volume_id"   { value = aws_ebs_volume.this.id }

