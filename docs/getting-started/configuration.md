# Configuration

## Fichier .env

Le fichier `/workspace/.env` contient les variables specifiques au produit. Il est **git-ignored** — utilisez `.env.example` comme reference.

### Variables requises

| Variable | Type | Description |
|----------|------|-------------|
| `GIT_USER` | string | Nom pour les commits git |
| `GIT_EMAIL` | email | Email pour les commits git |
| `APP_NAME` | string | Nom de l'application/produit |
| `ENVIRONMENT` | enum | `dev`, `staging`, `prod` |
| `MGMT_DOMAIN` | domain | Domaine du management plane (ex: `mgmt.example.com`) |
| `TF_STATE_BUCKET` | string | Nom du bucket S3 pour le state Terraform |
| `TF_STATE_ENDPOINT` | url | Endpoint Garage S3 pour le state |
| `VAULT_ADDR` | url | Adresse du serveur Vault |
| `CONSUL_HTTP_ADDR` | url | Adresse du serveur Consul |
| `NOMAD_ADDR` | url | Adresse du scheduler Nomad |

### Variables cloud (optionnelles, par provider)

=== "AWS"
    ```bash
    # Credentials: voir 1Password (S3 Garage compatible)
    AWS_REGION=eu-west-1
    ```

=== "GCP"
    ```bash
    GOOGLE_PROJECT=my-project-id
    GOOGLE_CREDENTIALS=...  # JSON service account
    ```

=== "Azure"
    ```bash
    ARM_SUBSCRIPTION_ID=...
    ARM_TENANT_ID=...
    ARM_CLIENT_ID=...
    ARM_CLIENT_SECRET=...
    ```

=== "Hetzner"
    ```bash
    HCLOUD_TOKEN=...
    ```

=== "Oracle Cloud"
    ```bash
    OCI_TENANCY_OCID=...
    OCI_USER_OCID=...
    OCI_FINGERPRINT=...
    OCI_KEY_PATH=...            # PLACEHOLDER
    ```

### Secrets

Les secrets sensibles (tokens, passwords) sont geres via **1Password** :

```bash
# Stocker un secret
/secret --push VAULT_TOKEN=hvs.xxxx

# Recuperer un secret
/secret --get VAULT_TOKEN
```

1Password est le gestionnaire principal (99%). Les variables d'environnement servent de fallback.

## Inventory

Le repertoire `inventory/` est l'unique element qui change entre produits :

```text
inventory/
├── config.hcl          # Config Terragrunt (backend, providers)
├── providers.tfvars    # Providers actifs et leurs parametres
├── stacks.tfvars       # Stacks a deployer
├── ansible/
│   └── hosts.yml       # Machines cibles Ansible
└── secrets.ref         # References Vault/1Password
```

!!! warning "Protection"
    Le repertoire `inventory/` n'est jamais ecrase par `/update`. C'est la seule zone libre du produit.
