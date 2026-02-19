<!-- updated: 2026-02-19T15:10:00Z -->
# GitHub Configuration

## Purpose

GitHub-specific configurations: workflows and CI/CD automation.

## Structure

```text
.github/
├── workflows/          # GitHub Actions
│   ├── docker-images.yml
│   └── CLAUDE.md
└── CLAUDE.md           # This file
```

## Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| docker-images.yml | push/PR/schedule | Build and push devcontainer images |

## Conventions

- Workflows use reusable actions where possible
- Secrets stored in GitHub repository settings
- Branch protection on main
- Action SHAs pinned with version comments
