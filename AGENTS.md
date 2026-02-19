<!-- updated: 2026-02-19T15:10:00Z -->
# Specialist Agents

## Primary — Infrastructure

| Agent | Purpose | When |
|-------|---------|------|
| `devops-orchestrator` | Coordination infra, security, cost | `/infra`, deployments complexes |
| `devops-specialist-infrastructure` | Terraform, Terragrunt, OpenTofu | Modules TF, state management |
| `devops-specialist-hashicorp` | Vault, Consul, Nomad, Packer | Management plane, secrets, orchestration |
| `devops-specialist-docker` | Dockerfile, Compose, images | Containerisation, Packer images |

## Primary — Cloud Providers

| Agent | Provider | When |
|-------|----------|------|
| `devops-specialist-aws` | AWS | Modules AWS, IAM, networking |
| `devops-specialist-gcp` | GCP | Modules GCP, IAM, BigQuery |
| `devops-specialist-azure` | Azure | Modules Azure, RBAC, AD |

## Primary — Languages (Tests)

| Agent | Purpose | When |
|-------|---------|------|
| `developer-specialist-go` | Terratest (Go) | Tests modules Terraform |
| `developer-specialist-python` | Molecule, Ansible | Tests roles Ansible, scripts |

## Supporting — Security & Quality

| Agent | Task | When |
|-------|------|------|
| `devops-specialist-security` | Vulnerability scanning, compliance | PR reviews, audit |
| `devops-specialist-finops` | Cost optimization, right-sizing | Infracost, resource analysis |
| `developer-executor-security` | Taint analysis, secrets detection | Code review |
| `developer-executor-shell` | Shell, Dockerfile, CI/CD safety | Scripts, pipelines |
| `developer-executor-quality` | Complexity, maintainability | Code review |

## Supporting — Review

| Agent | Task |
|-------|------|
| `developer-specialist-review` | Code review orchestration (5 sub-agents) |
| `developer-executor-correctness` | Invariants, state machines |
| `developer-executor-design` | Patterns, SOLID, DDD |

## Supporting — System Administration

| Agent | OS | When |
|-------|------|------|
| `devops-executor-linux` | Linux (systemd, networking) | Server config, hardening |
| `devops-executor-bsd` | FreeBSD, OpenBSD | BSD-based infra |

## Agent Behavior

Agents must:
- Consult context7 or official docs before generating non-trivial code
- Target current stable versions (Terraform 1.x, Ansible 2.x, Go 1.x)
- Validate with `tflint`, `ansible-lint`, `terraform validate` before returning
- Self-correct when linting or tests fail
- Return structured JSON for orchestrators
- Ask permission before destructive operations

## Delegation

Orchestrators delegate based on file types:
- `.tf` / `.hcl` → `devops-specialist-infrastructure`
- `vault/`, `consul/`, `nomad/` → `devops-specialist-hashicorp`
- `.yml` (ansible) → `developer-specialist-python`
- `_test.go` → `developer-specialist-go`
- `Dockerfile` → `devops-specialist-docker`
- `.sh` / CI files → `developer-executor-shell`
