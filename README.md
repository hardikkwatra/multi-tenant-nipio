Here’s a **perfect, submission-ready `README.md`** tailored to your exact working URLs and the Path B (nip.io) architecture. Copy-paste this into your repo root `README.md`.

```md
# Multi-Tenant Infra (No Domain) — Terraform + nip.io

This repository demonstrates a **multi-tenant, isolated infrastructure** provisioned with **Terraform** using **nip.io** for DNS (no domain purchase required).

Each tenant gets:
- **Dedicated VPC + public subnet** (network isolation)
- **Dedicated EC2 instance** running **Nginx** (compute isolation)
- **Dedicated EBS volume** mounted at `/data` (storage isolation)
- **HTTPS endpoint** (self-signed TLS for demo)
- **Per-tenant subdomain-style access** via **nip.io**

---

## Live Demo URLs (Working)

- **Tenant 1:** `https://tenant1.35.172.209.7.nip.io/`
- **Tenant 2:** `https://tenant2.3.91.45.200.nip.io/`

> Note: Your browser will show **“Not Secure”** because the TLS certificate is **self-signed** (accepted for this assignment). Use `curl -k` for verification.

---

## How nip.io Works (DNS Without Owning a Domain)

`nip.io` is a wildcard DNS service that resolves hostnames containing an IP address **directly to that IP**.

Example:
- `tenant1.35.172.209.7.nip.io` → resolves to `35.172.209.7`

This is used only for the demo to avoid domain/DNS management.  
In production, you would use a customer-owned domain (e.g., `tenant1.customer.com`) and managed DNS (Route53/Cloudflare/etc.).

---

## Repository Structure

```

.
├── envs/
│   └── demo/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── terraform.tfvars.example
├── modules/
│   └── tenant_aws_nip/
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── user_data.sh.tftpl
└── docs/
└── CUSTOMER_DOC.md

````

---

## Prerequisites

- **Terraform** `>= 1.5`
- **AWS CLI** configured
- AWS Account (Free Tier recommended)

Verify AWS auth:
```bash
aws sts get-caller-identity
````

Verify Terraform:

```bash
terraform version
```

---

## Quick Start (Deploy)

From repo root:

```bash
cd envs/demo
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

After apply, Terraform prints tenant URLs. You can re-check anytime:

```bash
terraform output tenant_urls
```

---

## Validate Deployment

### 1) DNS Resolution Check

Replace `<url>` with your tenant hostname:

```bash
dig tenant1.35.172.209.7.nip.io +short
dig tenant2.3.91.45.200.nip.io +short
```

Expected:

* `tenant1...` returns `35.172.209.7`
* `tenant2...` returns `3.91.45.200`

### 2) HTTPS Check (Self-Signed)

Use `-k` to skip certificate verification:

```bash
curl -k https://tenant1.35.172.209.7.nip.io/
curl -k https://tenant2.3.91.45.200.nip.io/
```

You should see tenant-specific content (“Hello from Tenant 1/2”).

---

## Add a New Tenant (Onboarding)

To add a new tenant, edit `envs/demo/terraform.tfvars` and add a new entry under `tenants`:

```hcl
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
```

Then apply:

```bash
terraform apply
```

Terraform will create only the new tenant resources and output the new URL.

---

## Tenant Isolation Model

This demo implements a **Dedicated Tier** isolation model:

* **Network isolation:** separate VPC per tenant
* **Compute isolation:** separate EC2 instance per tenant
* **Storage isolation:** separate EBS volume per tenant

This approach is easiest to reason about and provides strong isolation in a demo environment.

---

## Notes on Costs (Important)

* Public IPv4 and EBS volumes can incur costs depending on your AWS account tier.
* To avoid ongoing charges, destroy resources after demo.

---

## Cleanup (Destroy Everything)

```bash
cd envs/demo
terraform destroy
```

---

## Documentation

* Customer-facing documentation: `docs/CUSTOMER_DOC.md`

---

## Troubleshooting

### Browser shows “Not Secure”

Expected in demo because TLS is **self-signed**. Use:

```bash
curl -k https://tenantX.<ip>.nip.io/
```

### Tenant URL not responding immediately

User-data may still be installing packages. Wait 1–2 minutes and retry.

---

## Assignment Deliverables Mapping

✅ Terraform repository + README (this repo)
✅ Customer-facing documentation (`docs/CUSTOMER_DOC.md`)
✅ Loom video / screenshots:

* `terraform plan`
* `terraform apply`
* `dig tenantX... +short`
* Browser access to tenant endpoints

```
\
