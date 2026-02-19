# Changelog

Tous les changements notables de ce projet.

Le format est base sur [Keep a Changelog](https://keepachangelog.com/) et ce projet adhere au [Conventional Commits](https://www.conventionalcommits.org/).

## [0.1.0] - 2026-02-19

### Added

- **docs(project)**: Documentation projet initiale — vision, architecture, workflows ([`e04f7dd`](https://github.com/kodflow/infrastructure-template/commit/e04f7dd))
  - `docs/vision.md` — Objectifs, criteres de succes, principes de design
  - `docs/architecture.md` — System context, composants, flux de donnees, stack technique
  - `docs/workflows.md` — Setup nouveau produit, boucle dev, tests, CI/CD, sync template
  - `Makefile` — Targets infrastructure (init, plan, apply, test, drift, cost)
  - `.env.example` — Template variables d'environnement

### Infrastructure

- Structure prevue : `modules/` (cloud, services, base), `stacks/` (management, edge, compute, vpn)
- 6 providers cibles : AWS, GCP, Azure, Oracle Cloud, Hetzner, Heroku
- Management plane : Vault + Consul + Nomad + Garage S3 + LDAP + DNS
- Tests : Terratest (Go) + Molecule (Python)

### DevContainer

- 25 langages pre-configures avec linters et formatters
- 57 agents IA specialises (RLM architecture)
- 16 skills Claude Code (slash commands)
- 6 serveurs MCP (grepai, GitHub, GitLab, Codacy, Playwright, context7)
- 15 hooks (6 lifecycle + 9 Claude Code)
- 170+ patterns de design dans la base de connaissances
