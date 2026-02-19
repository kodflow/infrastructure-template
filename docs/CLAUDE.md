<!-- updated: 2026-02-19T15:10:00Z -->
# Documentation

## Purpose

Project documentation: vision, architecture, and development workflows for the infrastructure template.

## Structure

```text
docs/
├── vision.md        # Objectives, success criteria, target state
├── architecture.md  # Components, data flows, provider abstraction
├── workflows.md     # Development processes, CI/CD, deployment
└── CLAUDE.md        # This file
```

## Key Files

| File | Description |
|------|-------------|
| `vision.md` | Why this template exists, goals, success metrics |
| `architecture.md` | Management domain, provider abstraction, Terragrunt composition |
| `workflows.md` | New product setup, feature dev, PR flow, template sync |

## Conventions

- Written in French (project language)
- Focus on concepts and decisions, not implementation details
- Keep synchronized with root CLAUDE.md and Makefile targets
- MkDocs-compatible (see `/workspace/mkdocs.yml`)
