<!-- updated: 2026-02-19T00:00:00Z -->
# Architecture: infrastructure-template

## System Context

```
                         ┌─────────────────┐
                         │   Cloudflare     │
                         │ GeoDNS/LB/Proxy  │
                         └────────┬─────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                    │
     ┌────────▼──────┐  ┌───────▼───────┐  ┌────────▼──────┐
     │  Provider A   │  │  Provider B   │  │  Provider C   │
     │ (AWS/GCP/...) │  │ (Hetzner/...) │  │ (Azure/...)   │
     └────────┬──────┘  └───────┬───────┘  └────────┬──────┘
              │                  │                    │
              └──────────────────┼────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  mgmt.example.com      │
                    │  (3 serveurs)           │
                    │                        │
                    │  Vault │ Consul │ Nomad │
                    │  Garage S3 │ LDAP │ DNS │
                    └────────────────────────┘
```

## Template vs Product

```
infrastructure-template (ce repo)
│
├── 🔒 modules/      ──┐
├── 🔒 stacks/        │  Synchronise via /update
├── 🔒 ansible/       │  Jamais modifie dans un produit
├── 🔒 packer/        │
├── 🔒 ci/            │
├── 🔒 tests/       ──┘
│
└── ⚡ inventory/     ── Unique par produit
```

## Components

### modules/cloud/ — Abstractions Provider

Chaque module cloud expose une interface commune et implemente les specificites par provider.

| Module | Responsabilite |
|--------|---------------|
| `compute` | Instances/VMs — taille, image, SSH keys |
| `network` | VPC/VNet, subnets, peering, NAT |
| `storage` | Buckets S3/GCS/Blob, lifecycle rules |
| `dns` | Zones, records (hors Cloudflare) |

### modules/services/ — Services Deployables

| Module | Responsabilite |
|--------|---------------|
| `vault` | Cluster Vault (HA), unseal, policies |
| `consul` | Cluster Consul, service mesh, KV |
| `nomad` | Cluster Nomad (server + client), jobs |
| `garage` | Cluster Garage S3, buckets, replication |
| `ldap` | Serveur LDAP, schemas, users |
| `cloudflare` | Zones, DNS records, page rules, WAF |
| `vpn` | OpenVPN, WireGuard, PPTP — multi-protocole |
| `tunnel` | ngrok tunnels pour acces dev/debug |
| `ssl` | Certificats CF origin + Let's Encrypt fallback |

### modules/base/ — Fondations

| Module | Responsabilite |
|--------|---------------|
| `firewall` | Regles par provider (Security Groups, NSG, firewall rules) |
| `ssh` | Cles SSH, bastion, acces |

### stacks/ — Compositions Terragrunt

| Stack | Modules composes | Usage |
|-------|-----------------|-------|
| `management` | vault + consul + nomad + garage + ldap + dns | Management plane complet |
| `edge` | cloudflare + dns + ssl | Front / reverse proxy |
| `compute` | network + compute + firewall + ssh | Serveurs de base |
| `vpn` | vpn (multi-protocole) | Acces securise |

## Data Flow

```
1. Deploiement
   inventory/ → Terragrunt → Terraform → Provider API → Infrastructure

2. Configuration
   Ansible inventory → Playbooks → Roles → Serveurs configures

3. Secrets
   Vault ← Consul (discovery) ← Apps
   1Password → Vault (bootstrap initial)

4. State
   Terraform state → Garage S3 (mgmt.example.com)
   State lock → Consul KV

5. DNS
   Cloudflare → GeoDNS → Provider LB → Instances
   (fallback: DNS direct sans Cloudflare)

6. Monitoring
   Drift detection → Compare state vs real → Alert si divergence
   Infracost → Estimation sur chaque PR/MR
```

## Technology Stack

| Couche | Outil | Role |
|--------|-------|------|
| Provisioning | Terraform + Terragrunt | Infrastructure as Code |
| Configuration | Ansible | Configuration management |
| Images | Packer | Images immutables |
| Secrets | Vault | Dynamic secrets, encryption |
| Discovery | Consul | Service mesh, health checks |
| Orchestration | Nomad | Workload scheduling |
| Storage | Garage S3 | Object storage, TF state |
| Identity | LDAP | Authentification centralisee |
| Edge | Cloudflare | DNS, proxy, WAF, SSL |
| VPN | OpenVPN/WireGuard/PPTP | Acces securise |
| Tests | Terratest + Molecule | Validation infra |
| Cost | Infracost | Estimation pre-deploy |
| CI/CD | GitHub Actions + GitLab CI | Automation |

## Constraints

- **Self-hosted first**: management plane sur mgmt.example.com, pas de SaaS
- **Fail-safe**: chaque service a un fallback (CF → Let's Encrypt, Vault → 1Password)
- **Provider-agnostic**: modules abstraient les differences entre clouds
- **Single maintainer**: simplicite et automatisation maximales
- **Open source only**: zero dependance proprietaire
