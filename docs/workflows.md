<!-- updated: 2026-02-19T00:00:00Z -->
# Development Workflows

## Setup — New Product from Template

```bash
# 1. Clone le template
gh repo create mon-produit --template kodflow/infrastructure-template --private
cd mon-produit

# 2. Ouvrir dans le devcontainer
code .

# 3. Remplir l'inventory
#    inventory/config.hcl        → config Terragrunt
#    inventory/providers.tfvars  → providers actifs
#    inventory/stacks.tfvars     → stacks a deployer
#    inventory/ansible/hosts.yml → machines cibles
#    inventory/secrets.ref       → references Vault/1Password

# 4. Initialiser
make init

# 5. Planifier et deployer
make plan
make apply
```

## Development Loop

```
/plan "description"  →  Analyse + plan d'approche
/do                  →  Execution iterative du plan
make validate        →  terraform validate + ansible --syntax-check
make lint            →  tflint + ansible-lint
make test            →  Terratest + Molecule
make cost            →  Infracost estimation
/git --commit        →  Conventional commit + PR
/review              →  Code review multi-agents
```

## Testing Strategy

### Terraform — Terratest (Go)

```
tests/terratest/
├── modules/           # Un test par module
│   ├── compute_test.go
│   ├── network_test.go
│   └── vault_test.go
└── stacks/            # Tests d'integration par stack
    ├── management_test.go
    └── compute_test.go
```

Chaque test :
1. `terraform init` + `apply` dans un workspace ephemere
2. Valide les outputs et l'etat reel
3. `terraform destroy` en cleanup

### Ansible — Molecule (Python)

```
tests/molecule/
├── default/           # Scenario par defaut
│   ├── molecule.yml
│   ├── converge.yml
│   └── verify.yml
└── roles/             # Un scenario par role
    ├── vault/
    ├── consul/
    └── nomad/
```

Chaque scenario :
1. Cree un container/VM ephemere
2. Applique le role
3. Verifie l'etat avec testinfra
4. Detruit l'environnement

### Drift Detection

```bash
make drift
```

- Compare le state Terraform avec l'etat reel de l'infra
- Execute via cron (quotidien) ou manuellement
- Alerte si divergence detectee
- Genere un rapport diff

### Cost Estimation

```bash
make cost
```

- Infracost analyse le plan Terraform
- Affiche le cout mensuel estime
- Comparaison avec le cout actuel
- Integre dans les PR/MR comme commentaire

## Deployment

### Local

```bash
make plan             # Preview des changements
make apply            # Deploiement
make destroy          # Teardown (avec confirmation)
```

### GitHub Actions

```yaml
# ci/github/deploy.yml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:  # terraform validate + lint
  plan:      # terraform plan + infracost
  apply:     # terraform apply (main only)
  test:      # terratest + molecule
  drift:     # scheduled drift detection
```

### GitLab CI

```yaml
# ci/gitlab/.gitlab-ci.yml
stages:
  - validate
  - plan
  - apply
  - test
  - drift
```

## CI/CD Pipeline Stages

| Stage | Actions | Trigger |
|-------|---------|---------|
| **validate** | `terraform validate`, `tflint`, `ansible-lint`, `ansible --syntax-check` | Chaque push |
| **plan** | `terragrunt plan`, `infracost diff` | Chaque PR/MR |
| **test** | Terratest, Molecule | Chaque PR/MR |
| **apply** | `terragrunt apply` | Merge sur main |
| **drift** | Compare state vs reel | Cron quotidien |
| **cost** | Infracost report | Chaque PR/MR |

## Template Sync

### Double synchronisation via `/update`

```
/update
  ├── Sync devcontainer-template  → .devcontainer/, .claude/
  └── Sync infrastructure-template → modules/, stacks/, ansible/, packer/, ci/, tests/
```

### Detection automatique du profil

Le profil est detecte par la presence de repertoires :

| Condition | Profil | Sources |
|-----------|--------|---------|
| `modules/` OU `stacks/` OU `ansible/` existe | `infrastructure` | devcontainer-template + infrastructure-template |
| Sinon | `devcontainer` | devcontainer-template uniquement |

### Commandes disponibles

```bash
/update                       # Mise a jour complete (auto-detect profil)
/update --check               # Verifier les mises a jour disponibles
/update --profile             # Afficher le profil detecte
/update --component hooks     # Composant specifique (devcontainer)
/update --component modules   # Composant specifique (infrastructure)
/update --infra-only          # Sync infrastructure-template uniquement
/update --devcontainer-only   # Sync devcontainer-template uniquement
```

### Chemins proteges (jamais ecrases)

| Chemin | Raison |
|--------|--------|
| `inventory/` | Configuration produit-specifique |
| `terragrunt.hcl` | Config racine produit |
| `.env*` | Secrets et variables d'environnement |
| `CLAUDE.md` | Documentation projet |
| `AGENTS.md` | Agents projet |
| `README.md` | Readme projet |
| `Makefile` | Build projet |
| `docs/` | Documentation projet |

### Fichiers de version

- `.devcontainer/.template-version` — version du devcontainer-template
- `.infra-template-version` — version de l'infrastructure-template (genere automatiquement)

## Secrets Workflow

```
Bootstrap initial:
  1Password → Vault unseal keys + root token
  1Password → Provider credentials (AWS, GCP, etc.)

Runtime:
  Vault → Dynamic credentials (DB, cloud APIs)
  Vault → TLS certificates
  Vault → Encryption (transit)
  Consul → Service discovery tokens

Fallback:
  1Password → Si Vault indisponible
```

## Branch Conventions

- `feat/<description>` — nouvelle fonctionnalite (module, stack, role)
- `fix/<description>` — correction de bug
- Commits conventionnels : `feat:`, `fix:`, `docs:`, `test:`, `ci:`
- Jamais de commit direct sur `main`
