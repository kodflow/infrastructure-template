# Transport

Protocoles de communication et formats d'echange utilises par **infrastructure-template**.

## Protocoles

| Protocole | Direction | Port | TLS | Utilise par |
|-----------|-----------|------|:---:|-------------|
| HTTPS | Request/Response | 443 | :white_check_mark: | Terraform → Cloud APIs, Cloudflare API |
| SSH | Bidirectional | 22 | :white_check_mark: | Ansible → serveurs, bastion access |
| S3 (HTTP) | Request/Response | 3900 | :white_check_mark: | Terraform state → Garage S3 |
| Vault HTTP | Request/Response | 8200 | :white_check_mark: | Secrets, dynamic credentials, transit encryption |
| Consul HTTP | Request/Response | 8500 | :white_check_mark: | Service discovery, KV store, state lock |
| Consul DNS | Query/Response | 8600 | :x: | Service resolution interne |
| Nomad HTTP | Request/Response | 4646 | :white_check_mark: | Job scheduling, monitoring |
| Nomad RPC | RPC | 4647 | :white_check_mark: | Communication inter-noeuds Nomad |
| LDAP | Request/Response | 389/636 | LDAPS (636) | Authentification centralisee |
| OpenVPN | Tunnel | 1194 | :white_check_mark: | Acces VPN principal |
| WireGuard | Tunnel | 51820 | :white_check_mark: | VPN performant |
| PPTP | Tunnel | 1723 | :x: | VPN legacy fallback |
| Git/HTTPS | Push/Pull | 443 | :white_check_mark: | Code sync, CI/CD triggers |

## Formats d'echange

| Format | Content-Type | Utilise par | Detection |
|--------|-------------|-------------|:---------:|
| HCL | text/plain | Terraform modules, Terragrunt stacks | Explicite |
| JSON | application/json | Terraform state, Cloud APIs, MCP | Explicite |
| YAML | text/yaml | Ansible playbooks, CI/CD pipelines, Docker Compose | Explicite |
| Protocol Buffers | — | Consul gRPC, Nomad RPC interne | Deduit |
| PEM/X.509 | — | Certificats SSL/TLS, Vault transit | Explicite |
| SSH Keys | — | Ansible connexions, bastion access | Explicite |

!!! info "Detection"
    Les formats marques **Deduit** sont inferes des conventions du protocole (ex: Consul gRPC utilise Protobuf).

## Details des protocoles

### HTTPS — Cloud Provider APIs

Terraform communique avec chaque provider via leurs APIs REST/HTTPS. Les credentials sont obtenus dynamiquement via Vault ou configures via variables d'environnement.

```text
Terraform → Vault (8200/HTTPS) → Dynamic creds → Cloud API (443/HTTPS)
```

### S3 — Terraform State Backend

Le state Terraform est stocke dans Garage S3 (self-hosted, compatible AWS S3) sur le management plane :

```text
Terraform → Garage S3 (3900/HTTP) → State storage
Terraform → Consul KV (8500/HTTP) → State locking
```

### SSH — Configuration Management

Ansible se connecte aux serveurs cibles via SSH pour appliquer les roles de configuration :

```text
Ansible → Bastion (22/SSH) → Serveurs internes (22/SSH)
```

### Vault HTTP — Secrets Management

Vault fournit les secrets dynamiques, le transit encryption et les certificats TLS :

| Endpoint | Usage |
|----------|-------|
| `/v1/sys/health` | Health check |
| `/v1/auth/token/create` | Authentication |
| `/v1/secret/data/*` | KV secrets |
| `/v1/transit/encrypt/*` | Transit encryption |
| `/v1/pki/issue/*` | Certificats TLS |

### VPN — Acces securise

Multi-protocole selon les contraintes reseau :

| Protocole | Quand | Performance |
|-----------|-------|-------------|
| WireGuard | Defaut | Excellent (kernel-space) |
| OpenVPN | Fallback | Bon (userspace) |
| IPsec/IKEv2 | Corporate | Bon (natif iOS/macOS) |
| PPTP | Legacy | Faible (dernier recours) |
