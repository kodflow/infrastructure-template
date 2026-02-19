# Flux de donnees

## Deploiement

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {
  'primaryColor': '#9D76FB1a',
  'primaryBorderColor': '#9D76FB',
  'primaryTextColor': '#d4d8e0',
  'lineColor': '#d4d8e0',
  'textColor': '#d4d8e0'
}}}%%
sequenceDiagram
  participant M as Maintainer
  participant TG as Terragrunt
  participant TF as Terraform
  participant S3 as Garage S3
  participant V as Vault
  participant C as Cloud Provider

  M->>TG: make plan (inventory/)
  TG->>S3: Lock state
  TG->>TF: terraform plan (module)
  TF->>V: Request credentials
  V-->>TF: Dynamic credentials
  TF->>C: Provider API calls
  C-->>TF: Resource state
  TF->>S3: Store state
  TG-->>M: Plan output
  M->>TG: make apply
  TG->>TF: terraform apply
  TF->>C: Create/Update resources
  TF->>S3: Update state
  TG->>S3: Release lock
```

## Gestion des secrets

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {
  'primaryColor': '#9D76FB1a',
  'primaryBorderColor': '#9D76FB',
  'primaryTextColor': '#d4d8e0',
  'lineColor': '#d4d8e0',
  'textColor': '#d4d8e0'
}}}%%
flowchart TB
  OP[1Password]:::external -->|Bootstrap initial| V[Vault]:::data
  V -->|Dynamic credentials| TF[Terraform]:::primary
  V -->|Transit encryption| Apps[Applications]:::primary
  V -->|TLS certificates| SSL[SSL/TLS]:::primary
  Consul[Consul]:::data -->|Service discovery| Apps
  OP -->|Fallback si Vault down| Apps

  classDef primary fill:#9D76FB1a,stroke:#9D76FB,color:#d4d8e0
  classDef data fill:#76fb9d1a,stroke:#76fb9d,color:#d4d8e0
  classDef external fill:#6c76931a,stroke:#6c7693,color:#d4d8e0
```

| Etape | Source | Destination | Protocole |
|-------|--------|-------------|-----------|
| Bootstrap | 1Password | Vault unseal + root token | `op://` CLI |
| Provider creds | 1Password | Vault | `op://` CLI |
| Dynamic creds | Vault | Terraform | HTTPS API (8200) |
| Discovery tokens | Consul | Applications | HTTP API (8500) |
| Fallback | 1Password | Applications | `op://` CLI |

## State Terraform

```text
State: Terraform → Garage S3 (mgmt.example.com:3900)
Lock:  Terraform → Consul KV (mgmt.example.com:8500)
```

Le backend est configure dans `inventory/config.hcl` :

- **Bucket** : `TF_STATE_BUCKET` sur Garage S3 (self-hosted, compatible AWS S3)
- **Lock** : Consul KV pour le locking distribue
- **Encryption** : Vault Transit pour le chiffrement at-rest

## DNS et Edge

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {
  'primaryColor': '#9D76FB1a',
  'primaryBorderColor': '#9D76FB',
  'primaryTextColor': '#d4d8e0',
  'lineColor': '#d4d8e0',
  'textColor': '#d4d8e0'
}}}%%
flowchart LR
  Client[Client]:::external -->|DNS query| CF[Cloudflare<br/>GeoDNS + WAF]:::external
  CF -->|Proxied| LB[Load Balancer]:::primary
  LB --> I1[Instance 1]:::primary
  LB --> I2[Instance 2]:::primary

  Client2[Client]:::external -->|Fallback sans CF| DNS[DNS Direct]:::primary
  DNS --> I1

  classDef primary fill:#9D76FB1a,stroke:#9D76FB,color:#d4d8e0
  classDef external fill:#6c76931a,stroke:#6c7693,color:#d4d8e0
```

Le template fonctionne avec **et** sans Cloudflare :

- **Avec Cloudflare** : GeoDNS, LB, WAF, SSL origin certificates
- **Sans Cloudflare** : DNS direct + Let's Encrypt pour SSL

## CI/CD

| Stage | Actions | Trigger |
|-------|---------|---------|
| **validate** | `terraform validate`, `tflint`, `ansible-lint` | Chaque push |
| **plan** | `terragrunt plan`, `infracost diff` | Chaque PR/MR |
| **test** | Terratest, Molecule | Chaque PR/MR |
| **apply** | `terragrunt apply` | Merge sur main |
| **drift** | Compare state vs reel | Cron quotidien |
| **cost** | Infracost report | Chaque PR/MR |
