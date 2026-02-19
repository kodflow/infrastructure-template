# Architecture

Vue progressive de l'architecture infrastructure-template, du contexte systeme aux composants internes.

## Navigation

| Niveau | Diagramme | Audience | Focus |
|--------|-----------|----------|-------|
| [Contexte](#system-context) | C4 Context | Tous | Le template dans son ecosysteme |
| [Composants](components.md) | C4 Container | Architectes | Modules, stacks, services |
| [Flux de donnees](flow.md) | Sequence | Developpeurs | Deploiement, secrets, state |

## System Context

```mermaid
C4Context
  title System Context — infrastructure-template

  Person(maintainer, "Maintainer", "Kodflow — maintient le template et deploie les produits")

  System(template, "infrastructure-template", "Template IaC reproductible : modules TF, stacks TG, roles Ansible, pipelines CI/CD")

  System_Ext(cloudflare, "Cloudflare", "GeoDNS, LB, WAF, SSL, proxy")
  System_Ext(clouds, "Cloud Providers", "AWS, GCP, Azure, Oracle, Hetzner, Heroku")
  System_Ext(github, "GitHub / GitLab", "CI/CD, PRs/MRs, code review")
  System_Ext(onepassword, "1Password", "Secrets fallback, VPN configs, service accounts")

  System(mgmt, "mgmt.example.com", "Management plane : Vault, Consul, Nomad, Garage S3, LDAP, DNS")

  Rel(maintainer, template, "Clone, plan, apply, review")
  Rel(template, clouds, "Terraform apply", "HCL/JSON over HTTPS")
  Rel(template, mgmt, "State storage, secrets, discovery", "S3/HTTP/gRPC")
  Rel(template, github, "Push, PR, CI/CD", "Git/HTTPS")
  Rel(template, cloudflare, "DNS, proxy config", "HTTPS API")
  Rel(mgmt, clouds, "Dynamic credentials", "Vault HTTPS")
  Rel(maintainer, onepassword, "Bootstrap secrets", "op:// CLI")

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

### Interactions cles

| De | Vers | Protocole | Objectif |
|----|------|-----------|----------|
| Maintainer | Template | CLI local | `make plan`, `make apply`, `/git` |
| Template | Cloud Providers | HTTPS (Terraform) | Provisioning infrastructure |
| Template | mgmt.example.com | S3/HTTP | State TF, secrets Vault, discovery Consul |
| Template | GitHub/GitLab | Git/HTTPS | CI/CD pipelines, code review |
| Template | Cloudflare | HTTPS API | DNS, proxy, WAF configuration |
| mgmt | Cloud Providers | Vault HTTPS | Credentials dynamiques |
| Maintainer | 1Password | `op://` CLI | Bootstrap initial des secrets |

### Dependances externes

| Systeme | Type | Criticite |
|---------|------|-----------|
| Cloud Providers | Provisioning cible | Haute — sans provider, pas d'infra |
| mgmt.example.com | Management plane | Haute — state, secrets, discovery |
| Cloudflare | Edge/Proxy | Moyenne — fallback Let's Encrypt |
| 1Password | Secret bootstrap | Basse — fallback env vars |
| GitHub/GitLab | CI/CD | Moyenne — deploiement local possible |
