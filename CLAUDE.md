<!-- updated: 2026-02-19T15:10:00Z -->
# infrastructure-template

## Purpose

Template de base pour toute infrastructure. Replique sur 1000+ produits, seul l'inventory change par projet. Modules Terraform, roles Ansible, stacks Terragrunt et pipelines CI/CD sont synchronises depuis ce template.

## Project Structure

```
/workspace
├── modules/              # Terraform modules (atomiques, multi-provider)
│   ├── cloud/            #   compute, network, storage, dns
│   ├── services/         #   vault, consul, nomad, garage, ldap, cloudflare, vpn, tunnel, ssl
│   └── base/             #   firewall, ssh
├── stacks/               # Terragrunt stacks (compositions de modules)
│   ├── management/       #   vault+consul+nomad+garage+ldap+dns
│   ├── edge/             #   cloudflare+dns+ssl
│   ├── compute/          #   network+compute+firewall
│   └── vpn/              #   openvpn+wireguard+pptp
├── ansible/              # Roles et playbooks
│   ├── roles/
│   └── playbooks/
├── packer/               # Images machine par provider
├── ci/                   # Pipelines (GitHub Actions + GitLab CI)
├── tests/                # Terratest + Molecule
├── inventory/            # DYNAMIQUE — unique par produit
├── docs/                 # Documentation
├── terragrunt.hcl        # Root config (backend Garage S3)
├── Makefile              # deploy, plan, test, drift, cost
├── AGENTS.md             # Specialist agents
└── CLAUDE.md             # This file
```

## Tech Stack

- **IaC**: Terraform, Terragrunt, Packer
- **Config**: Ansible
- **Orchestration**: Nomad (client + server)
- **Service mesh**: Consul
- **Secrets**: Vault (99%) + 1Password (fallback)
- **Storage**: Garage S3 (state backend + object storage)
- **Identity**: LDAP
- **Edge**: Cloudflare (proxy/GeoDNS/LB/SSL) + Let's Encrypt fallback
- **VPN**: OpenVPN, WireGuard, PPTP
- **Tunneling**: ngrok
- **CI/CD**: GitHub Actions, GitLab CI
- **Tests**: Terratest (Go), Molecule (Python), Infracost
- **Providers**: AWS, GCP, Azure, Oracle Cloud, Hetzner, Heroku

## How to Work

1. **New product**: clone template, fill `inventory/`, run `make plan`
2. **New feature**: `/plan "description"` → `/do` → `/git --commit`
3. **Bug fix**: `/plan "description"` → `/do` → `/git --commit`
4. **Code review**: `/review` → specialist agents
5. **Sync template**: `/update` (devcontainer + infra-template)

## Key Principles

- **Inventory-driven**: toute specificite produit dans `inventory/`, jamais dans les modules
- **Provider-agnostic**: chaque module cloud/ abstrait les differences entre providers
- **Composition**: les stacks composent des modules via Terragrunt
- **Test everything**: Terratest pour TF, Molecule pour Ansible, Infracost pour les couts
- **Fail-safe**: fonctionne avec et sans Cloudflare, avec et sans management domain

## Verification

```bash
make plan          # Terraform plan via Terragrunt
make apply         # Deploy
make test          # Terratest + Molecule
make drift         # Drift detection
make cost          # Infracost estimation
make lint          # tflint + ansible-lint
make validate      # terraform validate + ansible --syntax-check
```

## Management Domain

`mgmt.example.com` — 3 serveurs hebergeant :
- Garage S3 (TF state + object storage)
- Vault (secrets + dynamic credentials)
- Consul (service discovery + KV)
- Nomad (workload orchestration)
- LDAP (identity)
- DNS (internal resolution)

## Documentation

- [Vision](docs/vision.md) — objectifs, criteres de succes
- [Architecture](docs/architecture.md) — composants, flux de donnees
- [Workflows](docs/workflows.md) — processus de developpement
