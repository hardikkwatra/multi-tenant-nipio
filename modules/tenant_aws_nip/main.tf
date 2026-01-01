data "aws_availability_zones" "available" {}

# -------------------------
# Networking (isolated per tenant)
# -------------------------
resource "aws_vpc" "this" {
  cidr_block           = "10.${var.tenant_index}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "vpc-${var.tenant_name}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "igw-${var.tenant_name}" }
}

resource "aws_subnet" "public_a" {
  vpc_id                 = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "public-a-${var.tenant_name}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "rt-public-${var.tenant_name}" }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Security group: allow HTTP/HTTPS from internet
# -------------------------
resource "aws_security_group" "web_sg" {
  name   = "web-sg-${var.tenant_name}"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "HTTP (redirects to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg-${var.tenant_name}" }
}

# -------------------------
# AMI: Amazon Linux 2023
# -------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# -------------------------
# Compute: EC2 instance with user_data
# -------------------------
resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    tenant_name = var.tenant_name
    app_message = var.app_message
  })

  tags = { Name = "web-${var.tenant_name}" }
}

# -------------------------
# Separate storage: EBS volume + attachment
# -------------------------
resource "aws_ebs_volume" "this" {
  availability_zone = aws_subnet.public_a.availability_zone
  size              = var.volume_size_gb
  type              = "gp3"
  tags = { Name = "vol-${var.tenant_name}" }
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id
}

# -------------------------
# nip.io URL
# -------------------------
locals {
  nip_host = "${var.tenant_name}.${aws_instance.this.public_ip}.nip.io"
  url      = "https://${local.nip_host}"
}

