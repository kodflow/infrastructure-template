<!-- updated: 2026-02-19T00:00:00Z -->
# Vision: infrastructure-template

## Purpose

Template de base pour toute infrastructure, concu pour etre replique sur 1000+ produits. Seul l'inventory change d'un projet a l'autre. Tout le reste — modules Terraform, roles Ansible, stacks Terragrunt, pipelines CI/CD — est synchronise depuis ce template.

## Problem Statement

- Duplication massive de code infra entre projets
- Derive de configuration entre environnements
- Pas de standard commun pour le provisioning multi-cloud
- Difficulte a maintenir la coherence sur des centaines de produits
- Absence de tests, de drift detection et de cost estimation systematiques

## Target Users

Mainteneur unique (kodflow). Ce template sert de fondation personnelle pour toute infrastructure deployee, quel que soit le provider ou le produit.

## Goals

1. **Reproductibilite** — un nouveau produit se deploie en clonant le template et en remplissant l'inventory
2. **Provider-agnostic** — support natif AWS, GCP, Azure, Oracle Cloud, Hetzner, Heroku
3. **Management plane centralise** — mgmt.example.com (3 serveurs) avec Vault, Consul, Nomad, Garage S3, LDAP, DNS
4. **Double synchronisation** — `/update` synchronise depuis devcontainer-template ET infrastructure-template
5. **Qualite totale** — Terratest, Molecule, drift detection, Infracost sur chaque changement
6. **Multi-deploiement** — local, GitHub Actions, GitLab CI
7. **Securite zero-trust** — Vault pour 99% des secrets, 1Password en fallback

## Success Criteria

| Critere | Mesure |
|---------|--------|
| Temps de bootstrap | < 30 min pour un nouveau produit |
| Providers supportes | 6+ (AWS, GCP, Azure, Oracle, Hetzner, Heroku) |
| Couverture tests | 100% des modules Terraform (Terratest) |
| Couverture Ansible | 100% des roles (Molecule) |
| Drift detection | Execution quotidienne automatisee |
| Cost estimation | Infracost sur chaque PR/MR |
| Sync template | `/update` fonctionne sans conflit |

## Design Principles

- **DRY** — chaque module existe une seule fois, parametrise par variables
- **Composition over inheritance** — les stacks composent des modules, pas d'heritage profond
- **Inventory-driven** — toute specificite produit vit dans `inventory/`, jamais dans les modules
- **Fail-safe** — fonctionne avec ET sans Cloudflare, avec ET sans management domain
- **Open source only** — 100% HashiCorp, 100% open source, zero vendor lock-in
- **Test everything** — aucun module ne merge sans tests

## Non-Goals

- Interface web / dashboard (on utilise les CLI)
- Support de providers non-cloud (bare metal custom hors Hetzner)
- Multi-tenant (un repo = un produit)
- Kubernetes (Nomad est le choix d'orchestration)

## Key Decisions

| Decision | Choix | Rationale |
|----------|-------|-----------|
| IaC | Terraform + Terragrunt | Standard industrie, DRY via Terragrunt |
| Config management | Ansible | Agentless, idempotent, large ecosysteme |
| Orchestrateur | Nomad | Plus simple que K8s, integre nativement Vault/Consul |
| Service mesh | Consul | Decouverte de service + KV store + health checks |
| Secrets | Vault | Rotation automatique, dynamic secrets, transit encryption |
| Object storage | Garage S3 | Open source, self-hosted, compatible S3 |
| Reverse proxy | Cloudflare | GeoDNS, LB, WAF, SSL — avec fallback Let's Encrypt |
| State backend | Garage S3 | Self-hosted sur mgmt.example.com |
| Images | Packer | Images immutables par provider |
| VPN | OpenVPN + WireGuard + PPTP | Multi-protocole selon les contraintes |
| CI/CD | GitHub Actions + GitLab CI | Portabilite entre plateformes |
| Tests infra | Terratest + Molecule | Go pour TF, Python pour Ansible |
| Cost | Infracost | Estimation pre-deploy sur chaque PR |
