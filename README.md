# Multi-Tenant Infrastructure (No Domain) — Terraform + nip.io

This repository demonstrates a **multi-tenant infrastructure** provisioned using **Terraform**, where each tenant is deployed into an **isolated environment** without requiring the purchase of a domain.

The solution uses **nip.io** for DNS resolution, allowing each tenant to be accessed via a subdomain-style HTTPS endpoint that maps directly to a public IP address.

---

## 🚀 Live Demo (Working URLs)

- **Tenant 1:** https://tenant1.35.172.209.7.nip.io/
- **Tenant 2:** https://tenant2.3.91.45.200.nip.io/

> ⚠️ **Note:**  
> Browsers will show *“Not Secure”* warnings because this demo uses **self-signed TLS certificates** (acceptable for this assignment).  
> For verification, use `curl -k`.

---

## 🧩 What Each Tenant Gets

Each tenant is provisioned with **dedicated resources**:

- **Dedicated VPC & Subnet** (network isolation)
- **Dedicated EC2 instance** running **Nginx** (compute isolation)
- **Dedicated EBS volume** mounted at `/data` (storage isolation)
- **HTTPS endpoint** (self-signed certificate)
- **DNS hostname via nip.io**

This ensures strong logical isolation between tenants.

---

## 🌐 How nip.io Works (DNS Without a Domain)

`nip.io` is a wildcard DNS service that automatically resolves hostnames containing an IP address to that IP.

Example:
tenant1.35.172.209.7.nip.io → 35.172.209.7

yaml
Copy code

This allows us to simulate per-tenant subdomains **without owning or managing a domain**.  
In production, this would be replaced with customer-owned domains and managed DNS (Route53, Cloudflare, etc.).

---

## 📁 Repository Structure

.
├── envs/
│ └── demo/
│ ├── main.tf
│ ├── providers.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── terraform.tfvars.example
├── modules/
│ └── tenant_aws_nip/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── user_data.sh.tftpl
└── docs/
└── CUSTOMER_DOC.md

yaml
Copy code

---

## ✅ Prerequisites

- Terraform **>= 1.5**
- AWS CLI configured
- An AWS account (Free Tier recommended)

Verify authentication:
```bash
aws sts get-caller-identity
Verify Terraform:

bash
Copy code
terraform version
⚙️ Quick Start (Deploy)
From the repository root:

bash
Copy code
cd envs/demo
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
After apply, Terraform outputs tenant URLs automatically.

To re-check outputs:

bash
Copy code
terraform output tenant_urls
🔍 Validate Deployment
1️⃣ DNS Resolution
bash
Copy code
dig tenant1.35.172.209.7.nip.io +short
dig tenant2.3.91.45.200.nip.io +short
Expected:

Tenant 1 → 35.172.209.7

Tenant 2 → 3.91.45.200

2️⃣ HTTPS Access (Self-Signed)
bash
Copy code
curl -k https://tenant1.35.172.209.7.nip.io/
curl -k https://tenant2.3.91.45.200.nip.io/
Each endpoint returns tenant-specific content.

➕ Add a New Tenant (Onboarding)
Edit envs/demo/terraform.tfvars:

hcl
Copy code
tenants = {
  tenant1 = {
    instance_type  = "t3.micro"
    volume_size_gb = 8
    app_message    = "Hello from Tenant 1"
  }

  tenant2 = {
    instance_type  = "t3.micro"
    volume_size_gb = 8
    app_message    = "Hello from Tenant 2"
  }

  tenant3 = {
    instance_type  = "t3.micro"
    volume_size_gb = 8
    app_message    = "Hello from Tenant 3"
  }
}
Apply changes:

bash
Copy code
terraform apply
Terraform provisions only the new tenant.
