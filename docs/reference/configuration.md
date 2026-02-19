# Reference Configuration

## Variables d'environnement

### Requises

| Variable | Source | Type | Description |
|----------|--------|------|-------------|
| `GIT_USER` | `.env` | string | Nom pour commits git |
| `GIT_EMAIL` | `.env` | email | Email pour commits git |
| `APP_NAME` | `.env` | string | Nom de l'application/produit |
| `ENVIRONMENT` | `.env` | enum | `dev` / `staging` / `prod` |
| `MGMT_DOMAIN` | `.env` | domain | Domaine management plane (ex: `mgmt.example.com`) |
| `TF_STATE_BUCKET` | `.env` | string | Bucket S3 pour state Terraform |
| `TF_STATE_ENDPOINT` | `.env` | url | Endpoint Garage S3 |
| `S3_ACCESS_KEY` | 1Password | secret | Credentials S3 (Garage compatible) |
| `S3_SECRET_KEY` | 1Password | secret | Credentials S3 (Garage compatible) |
| `VAULT_ADDR` | `.env` | url | Adresse du serveur Vault |
| `VAULT_TOKEN` | 1Password | secret | Token Vault |
| `CONSUL_HTTP_ADDR` | `.env` | url | Adresse du serveur Consul |
| `CONSUL_HTTP_TOKEN` | 1Password | secret | Token Consul |
| `NOMAD_ADDR` | `.env` | url | Adresse du scheduler Nomad |
| `NOMAD_TOKEN` | 1Password | secret | Token Nomad |

### Optionnelles par provider

=== "AWS"
    | Variable | Description |
    |----------|-------------|
    | `AWS_REGION` | Region (defaut: eu-west-1) |

=== "GCP"
    | Variable | Description |
    |----------|-------------|
    | `GOOGLE_PROJECT` | ID projet GCP |
    | `GOOGLE_CREDENTIALS` | JSON service account |

=== "Azure"
    | Variable | Description |
    |----------|-------------|
    | `ARM_SUBSCRIPTION_ID` | Subscription ID |
    | `ARM_TENANT_ID` | Tenant ID |
    | `ARM_CLIENT_ID` | Client ID |
    | `ARM_CLIENT_SECRET` | Client secret |

=== "Oracle Cloud"
    | Variable | Description |
    |----------|-------------|
    | `OCI_TENANCY_OCID` | Tenancy OCID |
    | `OCI_USER_OCID` | User OCID |
    | `OCI_FINGERPRINT` | API key fingerprint |
    | `OCI_KEY_PATH` | Chemin cle privee |

=== "Hetzner"
    | Variable | Description |
    |----------|-------------|
    | `HCLOUD_TOKEN` | API token |

=== "Heroku"
    | Variable | Description |
    |----------|-------------|
    | `HEROKU_API_KEY` | API key |

=== "Edge & VPN"
    | Variable | Description |
    |----------|-------------|
    | `CLOUDFLARE_API_TOKEN` | Token API Cloudflare |
    | `CLOUDFLARE_ZONE_ID` | Zone ID Cloudflare |
    | `NGROK_AUTHTOKEN` | Auth ngrok (tunneling dev) |
    | `OPENVPN_CONFIG_PATH` | Chemin config OpenVPN |
    | `WIREGUARD_CONFIG_PATH` | Chemin config WireGuard |
    | `OP_SERVICE_ACCOUNT_TOKEN` | Token 1Password service account |

## Fichiers de configuration

| Fichier | Objet | Git-ignored |
|---------|-------|:-----------:|
| `.env` | Variables produit (secrets) | Oui |
| `.env.example` | Template avec valeurs par defaut | Non |
| `inventory/config.hcl` | Config Terragrunt backend (S3 + Consul lock) | Non |
| `inventory/providers.tfvars` | Providers actifs et parametres | Non |
| `inventory/stacks.tfvars` | Stacks a deployer | Non |
| `inventory/ansible/hosts.yml` | Inventaire Ansible (machines cibles) | Non |
| `terragrunt.hcl` | Config racine Terragrunt (backend, common vars) | Non |

## Makefile targets

| Target | Action |
|--------|--------|
| `make init` | `terragrunt init` — initialise les providers et le backend |
| `make plan` | `terragrunt run-all plan` — preview des changements |
| `make apply` | `terragrunt run-all apply` — deploiement |
| `make destroy` | `terragrunt run-all destroy` — destruction (avec confirmation) |
| `make validate` | `terraform validate` + `ansible --syntax-check` |
| `make lint` | `tflint` + `ansible-lint` |
| `make fmt` | `terraform fmt` recursive sur tous les modules |
| `make test` | Terratest (Go) + Molecule (Python) |
| `make drift` | Detection de drift entre state et infrastructure reelle |
| `make cost` | Infracost estimation des couts mensuels |
| `make clean` | Nettoyage des caches Terragrunt (`.terragrunt-cache/`) |
| `make help` | Liste toutes les targets disponibles |
