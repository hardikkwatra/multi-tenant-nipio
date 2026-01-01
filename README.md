# Multi-Tenant Infra (No Domain) — Terraform + nip.io

This repo deploys isolated tenant environments without buying a domain.
Each tenant gets:
- Dedicated VPC + subnet
- Dedicated EC2 instance running Nginx
- Dedicated EBS volume mounted at /data
- HTTPS endpoint (self-signed)
- DNS name via nip.io: https://tenantX.<public-ip>.nip.io

nip.io maps hostnames containing IPs to that IP automatically.

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured
- An AWS account (Free Tier recommended)

Check auth:
```bash
aws sts get-caller-identity

