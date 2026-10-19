<img width="198" height="2268" alt="image" src="https://github.com/user-attachments/assets/32624b7e-d5df-43ca-8a57-ff0ddff82e2d" /># Apstra Automation

Infrastructure-as-Code solution for deploying and validating Juniper Apstra blueprints, routing zones (VRFs), virtual networks, and supporting resources using Terraform, GitHub Actions, and Terraform Cloud.

This project demonstrates a complete GitOps-based network automation workflow:

```text
Git Commit
    ↓
Pull Request
    ↓
Network Standards Validation
    ↓
Terraform Plan
    ↓
Approval
    ↓
Merge
    ↓
Deploy DEV
    ↓
Apstra Build Validation
    ↓
Apstra Anomaly Validation
    ↓
Approve PROD
    ↓
Deploy PROD
```

Repository: https://github.com/millsy2000/apstra-automation

---

# Objectives

This project aims to demonstrate:

- Infrastructure as Code (IaC) for Apstra
- Multi-environment deployments
- Reusable Terraform modules
- GitHub Actions CI/CD
- Terraform Cloud integration
- GitOps workflows
- Automated network standards validation
- Apstra build error validation
- Apstra anomaly validation
- Production approval gates

---

# Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── validate.yml
│       ├── deploy-dev.yml
│       └── deploy-prod.yml
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   ├── backend.tf
│   │   └── outputs.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── provider.tf
│       ├── backend.tf
│       └── outputs.tf
│
├── modules/
│   ├── blueprint/
│   ├── tenant/
│   ├── vrf/
│   ├── virtual-network/
│   └── resource-pools/
│
├── scripts/
│   ├── network_standards.py
│   ├── apstra_build_validation.py
│   └── apstra_blueprint_validation.py
│
├── policies/
│   └── network-standards.yaml
│
├── tenants/
│   └── tenants.yaml
│
└── README.md
```

---

# Key Components

## Environments

The `environments` directory contains environment-specific Terraform configurations.

```text
environments/
├── dev/
└── prod/
```

Each environment:

- Uses a dedicated Terraform Cloud workspace
- Uses a dedicated Apstra blueprint
- Shares reusable modules
- Maintains separate state

Example:

```text
DEV
├── Workspace: apstra-dev
└── Blueprint: DEV

PROD
├── Workspace: apstra-prod
└── Blueprint: PROD
```

---

## Modules

### Blueprint Module

Creates the Apstra blueprint.

Outputs:

```hcl
output "blueprint_id"
```

which is consumed throughout the deployment.

---

### VRF Module

Creates an Apstra Routing Zone.

Outputs:

```hcl
routing_zone_id
```

used by Virtual Networks.

---

### Virtual Network Module

Creates:

- VLAN
- VNI
- Virtual Gateway
- Subnet

within an existing Routing Zone.

---

### Tenant Module

Creates:

```text
Tenant
│
├── VRF
│
└── Multiple Virtual Networks
```

using data from `tenants.yaml`.

---

# Tenant Definitions

Tenants are defined in a single YAML file:

```yaml
tenants:

  - tenant_name: FINANCE

    networks:

      - name: APP
        vlan: 100
        vni: 10100
        subnet: 10.100.100.0/24
        gateway: 10.100.100.1

      - name: DB
        vlan: 101
        vni: 10101
        subnet: 10.100.101.0/24
        gateway: 10.100.101.1
```

Benefits:

- Single source of truth
- Easy code review
- Consumed by Terraform
- Consumed by validation scripts

---

# Network Standards Validation

Network standards are defined in:

```text
policies/network-standards.yaml
```

Example:

```yaml
vlan:
  minimum: 100
  maximum: 999

vni:
  minimum: 10000
  maximum: 19999
```

Validation checks include:

- VLAN ranges
- VNI ranges
- Duplicate VLAN detection
- Duplicate VNI detection
- Tenant naming standards
- Network naming standards
- Gateway validation
- Subnet validation

The validation runs during Pull Requests before Terraform planning.

---

# Apstra Validation

## Build Error Validation

Script:

```text
scripts/apstra_build_validation.py
```

Queries:

```text
/api/blueprints/{blueprint_id}/errors
```

Validates:

- Build errors count
- Error severity
- Build failure details

Pipeline stops immediately if build errors exist.

Example:

```text
Terraform Apply
    ↓
Build Validation
    ↓
FAIL
```

---

## Anomaly Validation

Script:

```text
scripts/apstra_blueprint_validation.py
```

Validates:

- Critical anomalies
- Fabric health issues
- Connectivity anomalies
- Cabling anomalies

Only runs after build validation succeeds.

---

# CI/CD Workflows

## validate.yml

Trigger:

```text
Pull Request
```

Activities:

```text
Network Standards Validation
Terraform Init
Terraform Validate
Terraform Plan
```

Purpose:

- Prevent invalid changes reaching main
- Generate change plans for review

---

## deploy-dev.yml

Trigger:

```text
Push to Main
```

Activities:

```text
Terraform Apply
Build Validation
Anomaly Validation
```

Target:

```text
Terraform Cloud Workspace:
apstra-dev
```

---

## deploy-prod.yml

Trigger:

```text
Manual Workflow Dispatch
```

Activities:

```text
Terraform Apply
Build Validation
Anomaly Validation
```

Protected by:

```text
GitHub Environment Approval Gate
```

Target:

```text
Terraform Cloud Workspace:
apstra-prod
```

---

# Required GitHub Secrets

## DEV Environment

```text
APSTRA_URL
APSTRA_USERNAME
APSTRA_PASSWORD
TF_API_TOKEN
```

## PROD Environment

```text
APSTRA_URL
APSTRA_USERNAME
APSTRA_PASSWORD
TF_API_TOKEN
```

---

# Demonstration Walkthrough

## Scenario 1 – Add a New Tenant

Update:

```text
tenants/tenants.yaml
```

Add:

```yaml
- tenant_name: LEGAL
```

Create a Pull Request.

Demonstrate:

- Validation workflow
- Terraform plan
- Review process

---

## Scenario 2 – Standards Violation

Attempt:

```yaml
vlan: 100
```

where VLAN 100 already exists.

Show:

```text
Network Standards Validation Failed
```

before Terraform runs.

---

## Scenario 3 – Deploy to DEV

Merge the Pull Request.

Demonstrate:

```text
Deploy DEV Workflow
```

including:

- Terraform Apply
- Apstra Build Validation
- Apstra Anomaly Validation

---

## Scenario 4 – Production Promotion

Run:

```text
Deploy PROD
```

Demonstrate:

```text
Approval Required
```

before deployment proceeds.

---

# Future Enhancements

Potential future improvements:

- Terraform plan comments in Pull Requests
- Apstra probe validation
- Scheduled drift detection
- Automated inventory documentation
- Service health validation
- Module versioning
- Production promotion based on successful DEV validation
- Policy as Code using OPA or Sentinel

---

# Architecture Overview

```text
GitHub
   │
   ▼
Pull Request
   │
   ▼
Network Standards Validation
   │
   ▼
Terraform Plan
   │
   ▼
Approval
   │
   ▼
Merge
   │
   ▼
Terraform Cloud
   │
   ▼
Apstra Blueprint
   │
   ├── Build Validation
   ├── Anomaly Validation
   └── Future Probe Validation
```

This repository demonstrates a complete GitOps workflow for managing Juniper Apstra fabrics using Terraform, Terraform Cloud, and GitHub Actions.
