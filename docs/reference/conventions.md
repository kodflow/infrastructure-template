# Conventions

## Git

### Branches

| Pattern | Usage |
|---------|-------|
| `feat/<description>` | Nouvelle fonctionnalite (module, stack, role) |
| `fix/<description>` | Correction de bug |
| `docs/<description>` | Documentation |
| `test/<description>` | Tests |
| `ci/<description>` | CI/CD |

### Commits conventionnels

```
<type>(<scope>): <description>

[optional body]
```

| Type | Usage |
|------|-------|
| `feat` | Nouveau module, stack, role |
| `fix` | Correction |
| `refactor` | Restructuration sans changement fonctionnel |
| `docs` | Documentation |
| `test` | Tests (Terratest, Molecule) |
| `chore` | Maintenance |
| `ci` | Pipelines CI/CD |

### Regles

- **Jamais** de commit direct sur `main`
- **Jamais** de `--force` push (utiliser `--force-with-lease`)
- **Toujours** passer par une PR/MR avec review

## Terraform

- Modules atomiques dans `modules/` — un module = une responsabilite
- Variables dans `variables.tf`, outputs dans `outputs.tf`
- Provider-agnostic : variables conditionnelles par provider (AWS/GCP/Azure/etc.)
- State dans Garage S3, lock dans Consul KV
- Format : `terraform fmt -recursive` (ou `make fmt`)
- Validation : `make validate` avant chaque commit

## Terragrunt

- Stacks dans `stacks/` — compositions de modules via `dependency` blocks
- Config DRY : variables communes dans `terragrunt.hcl` racine
- Backend automatique : Garage S3 + Consul KV lock
- Injection de variables depuis `inventory/*.tfvars`

## Ansible

- Roles dans `ansible/roles/` — un role par service (vault, consul, nomad, etc.)
- Playbooks dans `ansible/playbooks/`
- Inventaire dans `inventory/ansible/hosts.yml`
- Lint : `ansible-lint` (ou `make lint`)
- Tests : Molecule + testinfra

## Structure modules/

Chaque module Terraform suit cette structure :

```text
modules/<category>/<name>/
├── main.tf          # Ressources principales
├── variables.tf     # Variables d'entree
├── outputs.tf       # Outputs du module
├── versions.tf      # Contraintes de version TF + providers
└── README.md        # Documentation du module
```

## Fichiers proteges

Ces chemins ne sont **jamais** ecrases lors d'une synchronisation template :

| Chemin | Raison |
|--------|--------|
| `inventory/` | Configuration specifique au produit |
| `terragrunt.hcl` | Config racine personnalisee |
| `.env*` | Secrets et variables locales |
| `Makefile` | Targets personnalisees |
| `docs/` | Documentation produit |
