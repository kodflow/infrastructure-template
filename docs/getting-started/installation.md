# Installation

## Depuis le template GitHub

```bash
# Creer un nouveau repo depuis le template
gh repo create mon-produit --template kodflow/infrastructure-template --private

# Cloner et ouvrir
cd mon-produit
code .
```

VS Code detecte automatiquement le `.devcontainer/` et propose d'ouvrir dans le container.

## Installation manuelle

```bash
git clone https://github.com/kodflow/infrastructure-template.git mon-produit
cd mon-produit
```

## Prerequis

| Outil | Version | Usage |
|-------|---------|-------|
| Docker | 24+ | DevContainer runtime |
| VS Code | 1.85+ | IDE avec extension DevContainers |
| `gh` CLI | 2.40+ | Template cloning (optionnel) |

## Outils inclus

Le DevContainer embarque tous les outils necessaires :

| Categorie | Outils |
|-----------|--------|
| **IaC** | Terraform, Terragrunt, Packer, Ansible |
| **Cloud CLI** | AWS CLI, gcloud, az, oci, hcloud, heroku |
| **HashiCorp** | Vault, Consul, Nomad (CLI clients) |
| **Reseau** | ping, dig, nmap, traceroute, mtr, tcpdump |
| **VPN** | OpenVPN, WireGuard, StrongSwan, PPTP |
| **Qualite** | ShellCheck, tflint, ansible-lint |

## Premier demarrage

Au premier lancement du container, l'environnement est configure automatiquement :

1. Creation des repertoires cache et configuration shell (Zsh + Oh My Zsh)
2. Configuration git (identite, GPG signing, SSL)
3. Connexion VPN au management plane (si configure)
4. Validation de l'environnement

L'ensemble est non-bloquant : meme si un service echoue (VPN, etc.), le container demarre normalement.
