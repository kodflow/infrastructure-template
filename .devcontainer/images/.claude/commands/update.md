---
name: update
description: |
  DevContainer Environment Update from official templates.
  Updates hooks, commands, agents, and settings from kodflow/devcontainer-template.
  If infrastructure profile detected, also syncs modules, stacks, ansible, packer, ci, tests
  from kodflow/infrastructure-template.
allowed-tools:
  - "Bash(curl:*)"
  - "Bash(git:*)"
  - "Bash(jq:*)"
  - "Bash(mkdir:*)"
  - "Read(**/*)"
  - "Write(.devcontainer/**/*)"
  - "Write(modules/**/*)"
  - "Write(stacks/**/*)"
  - "Write(ansible/**/*)"
  - "Write(packer/**/*)"
  - "Write(ci/**/*)"
  - "Write(tests/**/*)"
  - "Write(.infra-template-version)"
  - "WebFetch(*)"
  - "Task(*)"
---

# Update - DevContainer Environment Update

$ARGUMENTS

---

## Description

Updates the DevContainer environment from official templates.
Supports **dual-source sync** for infrastructure projects.

**API-FIRST approach**: Uses the GitHub API to dynamically discover
existing files instead of hardcoded lists.

**Template Profile Detection**: Automatically detects whether the project
inherits from `infrastructure-template` by checking for `modules/`, `stacks/`,
or `ansible/` directories. Infrastructure projects sync from both sources.

**DevContainer components** (from `devcontainer-template`):

- **Hooks** - Claude scripts (format, lint, security, etc.)
- **Commands** - Slash commands (/git, /search, etc.)
- **Agents** - Agent definitions (specialists, executors)
- **Lifecycle** - Lifecycle hooks (delegation stubs)
- **Image-hooks** - Hooks embedded in the Docker image (real logic)
- **Shared-utils** - Shared utilities (utils.sh)
- **Config** - p10k, settings.json
- **Compose** - docker-compose.yml (update devcontainer, preserve custom)
- **Grepai** - Optimized grepai configuration

**Infrastructure components** (from `infrastructure-template`, if detected):

- **Modules** - Terraform modules (`modules/`)
- **Stacks** - Terragrunt stacks (`stacks/`)
- **Ansible** - Roles and playbooks (`ansible/`)
- **Packer** - Machine images (`packer/`)
- **CI** - Pipeline definitions (`ci/`)
- **Tests** - Terratest + Molecule (`tests/`)

**Sources**:
- `github.com/kodflow/devcontainer-template` (always)
- `github.com/kodflow/infrastructure-template` (infrastructure profile only)

---

## Arguments

| Pattern | Action |
|---------|--------|
| (none) | Full update (both sources if infrastructure profile) |
| `--check` | Check for available updates |
| `--component <name>` | Update a specific component |
| `--profile` | Display detected template profile |
| `--infra-only` | Sync only from infrastructure-template |
| `--devcontainer-only` | Sync only from devcontainer-template |
| `--help` | Show help |

### Available components

**DevContainer components** (from `devcontainer-template`):

| Component | Path | Description |
|-----------|------|-------------|
| `hooks` | `.devcontainer/images/.claude/scripts/` | Claude scripts |
| `commands` | `.devcontainer/images/.claude/commands/` | Slash commands |
| `agents` | `.devcontainer/images/.claude/agents/` | Agent definitions |
| `lifecycle` | `.devcontainer/hooks/lifecycle/` | Lifecycle hooks (stubs) |
| `image-hooks` | `.devcontainer/images/hooks/` | Image-embedded lifecycle hooks |
| `shared-utils` | `.devcontainer/hooks/shared/utils.sh` | Shared hook utilities |
| `p10k` | `.devcontainer/images/.p10k.zsh` | Powerlevel10k config |
| `settings` | `.../images/.claude/settings.json` | Claude config |
| `compose` | `.devcontainer/docker-compose.yml` | Update devcontainer service |
| `grepai` | `.devcontainer/images/grepai.config.yaml` | grepai config |

**Infrastructure components** (from `infrastructure-template`, infrastructure profile only):

| Component | Path | Description |
|-----------|------|-------------|
| `modules` | `modules/` | Terraform modules |
| `stacks` | `stacks/` | Terragrunt stacks |
| `ansible` | `ansible/` | Roles and playbooks |
| `packer` | `packer/` | Machine images |
| `ci` | `ci/` | Pipeline definitions |
| `tests` | `tests/` | Terratest + Molecule |

---

## --help

```
═══════════════════════════════════════════════
  /update - Template Environment Update
═══════════════════════════════════════════════

Usage: /update [options]

Options:
  (none)                Full update (auto-detect profile)
  --check               Check for updates
  --component <name>    Update a component
  --profile             Show detected template profile
  --infra-only          Sync infrastructure-template only
  --devcontainer-only   Sync devcontainer-template only
  --help                Show this help

DevContainer components:
  hooks        Claude scripts (format, lint...)
  commands     Slash commands (/git, /search)
  agents       Agent definitions (specialists)
  lifecycle    Lifecycle hooks (delegation stubs)
  image-hooks  Image-embedded lifecycle hooks
  shared-utils Shared hook utilities (utils.sh)
  p10k         Powerlevel10k config
  settings     Claude settings.json
  compose      docker-compose.yml (devcontainer service)
  grepai       grepai config (provider, model)

Infrastructure components (infrastructure profile only):
  modules      Terraform modules
  stacks       Terragrunt stacks
  ansible      Roles and playbooks
  packer       Machine images
  ci           Pipeline definitions
  tests        Terratest + Molecule

Profile detection:
  modules/ OR stacks/ OR ansible/ exists → infrastructure
  Otherwise → devcontainer (single source)

Examples:
  /update                       Update everything (auto-detect)
  /update --check               Check for updates
  /update --profile             Show detected profile
  /update --component hooks     Hooks only
  /update --component modules   Terraform modules only
  /update --infra-only          Infrastructure sync only
  /update --devcontainer-only   DevContainer sync only

Sources:
  1. kodflow/devcontainer-template (always)
  2. kodflow/infrastructure-template (infrastructure profile)
═══════════════════════════════════════════════
```

---

## Overview

Template environment update using **RLM** patterns:

- **Environment Detection** - Detect container vs host context
- **Profile Detection** - Detect devcontainer vs infrastructure profile
- **Peek** - Verify connectivity and versions (both sources if infrastructure)
- **Discover** - Dynamically discover files via GitHub API (Git Trees for infra)
- **Validate** - Validate each download (no 404)
- **Synthesize** - Apply updates (5.1 DevContainer + 5.2 Infrastructure) and consolidated report

---

## Configuration

```yaml
# DevContainer source (always active)
DC_REPO: "kodflow/devcontainer-template"
DC_BRANCH: "main"
DC_BASE_URL: "https://raw.githubusercontent.com/${DC_REPO}/${DC_BRANCH}"
DC_API_URL: "https://api.github.com/repos/${DC_REPO}/contents"

# Infrastructure source (infrastructure profile only)
INFRA_REPO: "kodflow/infrastructure-template"
INFRA_BRANCH: "main"
INFRA_BASE_URL: "https://raw.githubusercontent.com/${INFRA_REPO}/${INFRA_BRANCH}"
INFRA_TREES_URL: "https://api.github.com/repos/${INFRA_REPO}/git/trees/${INFRA_BRANCH}?recursive=1"
```

---

## ZSH Compatibility (CRITICAL)

**The default shell is `zsh` (set via `chsh -s /bin/zsh` in Dockerfile).**
Claude Code's Bash tool executes commands using `$SHELL` (zsh), not bash.

**RULE: All inline scripts MUST be zsh-compatible.**

| Pattern | Status | Reason |
|---------|--------|--------|
| `for x in $VAR` | **BROKEN in zsh** | zsh does not split variables on IFS |
| `while IFS= read -r x; do` | **WORKS everywhere** | Portable bash/zsh |
| `for x in literal1 literal2` | **WORKS everywhere** | No variable expansion |

**Always use `while read` for iterating over command output:**

```bash
# CORRECT (works in both bash and zsh):
curl ... | jq ... | while IFS= read -r item; do
    [ -z "$item" ] && continue
    echo "$item"
done

# INCORRECT (breaks in zsh - variable not split):
ITEMS=$(curl ... | jq ...)
for item in $ITEMS; do
    echo "$item"
done
```

**For the reference script:** Write to a temp file and execute with `bash` explicitly:
```bash
# Write script to temp file, then run with bash
cat > /tmp/update-script.sh << 'SCRIPT'
#!/bin/bash
# ... script content ...
SCRIPT
bash /tmp/update-script.sh && rm -f /tmp/update-script.sh
```

---

## Phase 1.0: Environment Detection (NEW)

**MANDATORY: Detect execution context before any operation.**

```yaml
environment_detection:
  1_container_check:
    action: "Detect if running inside container"
    method: "[ -f /.dockerenv ]"
    output: "IS_CONTAINER (true|false)"

  2_devcontainer_check:
    action: "Check DEVCONTAINER env var"
    method: "[ -n \"${DEVCONTAINER:-}\" ]"
    note: "Set by VS Code when attached to devcontainer"

  3_determine_target:
    container_mode:
      target: "/workspace/.devcontainer/images/.claude"
      behavior: "Update template source (requires rebuild)"
      propagation: "Changes applied at next container start"

    host_mode:
      target: "$HOME/.claude"
      behavior: "Update user Claude configuration"
      propagation: "Immediate (no rebuild needed)"

  4_display_context:
    output: |
      Environment: {CONTAINER|HOST}
      Update target: {path}
      Mode: {template|user}
```

**Implementation:**

```bash
# Detect environment context
detect_context() {
    # Check if running inside container
    if [ -f /.dockerenv ]; then
        CONTEXT="container"
        UPDATE_TARGET="/workspace/.devcontainer/images/.claude"
        echo "Detected: Container environment"
    else
        CONTEXT="host"
        UPDATE_TARGET="$HOME/.claude"
        echo "Detected: Host machine"
    fi

    # Additional checks
    if [ -n "${DEVCONTAINER:-}" ]; then
        echo "  (DevContainer detected via DEVCONTAINER env var)"
    fi

    echo "Update target: $UPDATE_TARGET"
    echo "Mode: $CONTEXT"
}

# Call at start of update
detect_context
```

**Output Phase 1.0:**

```
═══════════════════════════════════════════════
  /update - Environment Detection
═══════════════════════════════════════════════

  Environment: HOST MACHINE
  Update target: /home/user/.claude
  Mode: user configuration

  Changes will be:
    - Applied immediately
    - No container rebuild needed
    - Synced to container via postStart.sh

═══════════════════════════════════════════════
```

Or in container:

```
═══════════════════════════════════════════════
  /update - Environment Detection
═══════════════════════════════════════════════

  Environment: DEVCONTAINER
  Update target: /workspace/.devcontainer/images/.claude
  Mode: template source

  Changes will be:
    - Applied to template files
    - Require container rebuild to propagate
    - Or wait for next postStart.sh sync

═══════════════════════════════════════════════
```

---

## Phase 1.5: Template Profile Detection

**MANDATORY: Detect template profile after environment detection.**

Detection is based on directory presence — no marker files needed:

```yaml
profile_detection:
  rule: |
    If modules/ OR stacks/ OR ansible/ exists → "infrastructure"
    Otherwise → "devcontainer"

  infrastructure:
    sources:
      - "kodflow/devcontainer-template (core)"
      - "kodflow/infrastructure-template (infra)"
    sync_dirs:
      - modules/
      - stacks/
      - ansible/
      - packer/
      - ci/
      - tests/

  devcontainer:
    sources:
      - "kodflow/devcontainer-template (core)"
```

**Implementation:**

```bash
# Detect template profile based on directory structure
detect_template_profile() {
    if [ -d "modules" ] || [ -d "stacks" ] || [ -d "ansible" ]; then
        PROFILE="infrastructure"
        INFRA_REPO="kodflow/infrastructure-template"
        INFRA_BRANCH="main"
        INFRA_BASE="https://raw.githubusercontent.com/${INFRA_REPO}/${INFRA_BRANCH}"
        INFRA_TREES="https://api.github.com/repos/${INFRA_REPO}/git/trees/${INFRA_BRANCH}?recursive=1"
    else
        PROFILE="devcontainer"
        INFRA_REPO=""
    fi
}

detect_template_profile
```

**Output Phase 1.5 (infrastructure):**

```
═══════════════════════════════════════════════
  Template Profile Detection
═══════════════════════════════════════════════
  Profile  : infrastructure
  Sources  :
    1. kodflow/devcontainer-template (core)
    2. kodflow/infrastructure-template (infra)
═══════════════════════════════════════════════
```

**Output Phase 1.5 (devcontainer):**

```
═══════════════════════════════════════════════
  Template Profile Detection
═══════════════════════════════════════════════
  Profile  : devcontainer
  Sources  :
    1. kodflow/devcontainer-template (core)
═══════════════════════════════════════════════
```

**Protected paths** (NEVER overwritten by infrastructure sync):

| Path | Reason |
|------|--------|
| `inventory/` | Product-specific configuration |
| `terragrunt.hcl` | Root config specific to product |
| `.env*` | Secrets and environment variables |
| `CLAUDE.md` | Project documentation |
| `AGENTS.md` | Project agents definition |
| `README.md` | Project readme |
| `Makefile` | Project build configuration |
| `docs/` | Project documentation |

---

## Phase 2.0: Peek (Version Check)

```yaml
peek_workflow:
  1_dc_connectivity:
    action: "Verify GitHub connectivity (devcontainer-template)"
    tool: WebFetch
    url: "https://api.github.com/repos/kodflow/devcontainer-template/commits/main"

  2_dc_local_version:
    action: "Read local devcontainer version"
    tool: Read
    file: ".devcontainer/.template-version"

  3_infra_connectivity:
    condition: "PROFILE == infrastructure"
    action: "Verify GitHub connectivity (infrastructure-template)"
    tool: WebFetch
    url: "https://api.github.com/repos/kodflow/infrastructure-template/commits/main"

  4_infra_local_version:
    condition: "PROFILE == infrastructure"
    action: "Read local infrastructure version"
    tool: Read
    file: ".infra-template-version"
```

**Output Phase 2.0 (infrastructure profile):**

```
═══════════════════════════════════════════════
  /update - Peek Analysis
═══════════════════════════════════════════════

  DevContainer source:
    Connectivity   : ✓ GitHub API accessible
    Local version  : abc1234 (2024-01-15)
    Remote version : def5678 (2024-01-20)
    Status: UPDATE AVAILABLE

  Infrastructure source:
    Connectivity   : ✓ GitHub API accessible
    Local version  : (none - first sync)
    Remote version : ghi9012 (2024-01-18)
    Status: UPDATE AVAILABLE

═══════════════════════════════════════════════
```

---

## Phase 3.0: Discover (API-FIRST - Dynamic Discovery)

**CRITICAL RULE: Always use the GitHub API to discover files.**

NEVER use hardcoded lists. Files can be added,
renamed, or deleted in the source template.

```yaml
discover_workflow:
  strategy: "API-FIRST"

  components:
    hooks:
      api: "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/scripts"
      filter: "*.sh"
      local_path: ".devcontainer/images/.claude/scripts/"

    commands:
      api: "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/commands"
      filter: "*.md"
      local_path: ".devcontainer/images/.claude/commands/"

    agents:
      api: "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/agents"
      filter: "*.md"
      local_path: ".devcontainer/images/.claude/agents/"

    lifecycle:
      api: "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/hooks/lifecycle"
      filter: "*.sh"
      local_path: ".devcontainer/hooks/lifecycle/"

    image-hooks:
      api: "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/hooks"
      recursive: true
      local_path: ".devcontainer/images/hooks/"
      note: "Image-embedded lifecycle hooks (real logic)"

    shared-utils:
      raw_url: "https://raw.githubusercontent.com/kodflow/devcontainer-template/main/.devcontainer/hooks/shared/utils.sh"
      local_path: ".devcontainer/hooks/shared/utils.sh"
      note: "Needed by initialize.sh (runs on host)"

    p10k:
      raw_url: "https://raw.githubusercontent.com/kodflow/devcontainer-template/main/.devcontainer/images/.p10k.zsh"
      local_path: ".devcontainer/images/.p10k.zsh"

    settings:
      raw_url: "https://raw.githubusercontent.com/kodflow/devcontainer-template/main/.devcontainer/images/.claude/settings.json"
      local_path: ".devcontainer/images/.claude/settings.json"

    compose:
      strategy: "REPLACE from template, PRESERVE custom services"
      raw_url: "https://raw.githubusercontent.com/kodflow/devcontainer-template/main/.devcontainer/docker-compose.yml"
      local_path: ".devcontainer/docker-compose.yml"
      note: |
        - If file absent -> download complete
        - If file exists:
          1. Extract custom services (not devcontainer)
          2. Replace entirely from template (preserves order/comments)
          3. Merge extracted custom services back
        - Order: devcontainer -> custom
        - Backup created before modification, restored on failure
        - Uses mikefarah/yq (Go version) for merge
        - Note: Ollama runs on HOST (installed via initialize.sh)

    grepai:
      raw_url: "https://raw.githubusercontent.com/kodflow/devcontainer-template/main/.devcontainer/images/grepai.config.yaml"
      local_path: ".devcontainer/images/grepai.config.yaml"
      note: "Optimized config with bge-m3 model (best accuracy)"
```

**Discover implementation (DevContainer):**

```bash
# Function to list files from a directory via GitHub API
list_remote_files() {
    local api_url="$1"
    local filter="$2"

    curl -sL "$api_url" | jq -r '.[].name' | grep -E "$filter" || true
}

# Example: discover scripts
SCRIPTS=$(list_remote_files \
    "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/scripts" \
    '\.sh$')

# Example: discover commands
COMMANDS=$(list_remote_files \
    "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/commands" \
    '\.md$')

# Example: discover agents
AGENTS=$(list_remote_files \
    "https://api.github.com/repos/kodflow/devcontainer-template/contents/.devcontainer/images/.claude/agents" \
    '\.md$')
```

**Discover implementation (Infrastructure — Git Trees API):**

Uses a single API call to discover all infrastructure files (saves API quota):

```bash
# Discover infrastructure files via Git Trees API (1 request for entire tree)
discover_infra_files() {
    if [ "$PROFILE" != "infrastructure" ]; then
        return 0
    fi

    # Single API call for entire repository tree
    INFRA_TREE=$(curl -sL "$INFRA_TREES" | jq -r '.tree[] | select(.type == "blob") | .path')

    # Filter relevant directories
    INFRA_FILES=$(echo "$INFRA_TREE" | grep -E '^(modules|stacks|ansible|packer|ci|tests)/' || true)

    if [ -z "$INFRA_FILES" ]; then
        echo "  ⚠ No infrastructure files found in template"
        return 0
    fi

    INFRA_FILE_COUNT=$(echo "$INFRA_FILES" | wc -l | tr -d ' ')
    echo "  Discovered $INFRA_FILE_COUNT infrastructure files"
}
```

**Infrastructure sync directories:**

| Source path | Local path | Description |
|-------------|------------|-------------|
| `modules/**` | `modules/` | Terraform modules |
| `stacks/**` | `stacks/` | Terragrunt stacks |
| `ansible/**` | `ansible/` | Roles and playbooks |
| `packer/**` | `packer/` | Machine images |
| `ci/**` | `ci/` | Pipeline definitions |
| `tests/**` | `tests/` | Terratest + Molecule |

---

## Phase 4.0: Validate (Download with Verification)

**CRITICAL RULE: Always validate downloads before writing.**

NEVER write a file without verifying that the download succeeded.
Detect 404 errors and other failures.

```yaml
validate_workflow:
  rule: "NEVER write files without validation"

  checks:
    - "HTTP status 200 (not 404)"
    - "Content is not empty"
    - "Content is not HTML error page"
    - "Content starts with expected pattern"

  on_failure:
    - "Log error"
    - "Skip file"
    - "Continue with next file"
```

**Validate implementation:**

```bash
# Secure download function with validation
safe_download() {
    local url="$1"
    local output="$2"
    local temp_file=$(mktemp)

    # Download with HTTP code
    http_code=$(curl -sL -w "%{http_code}" -o "$temp_file" "$url")

    # Validate the download
    if [ "$http_code" != "200" ]; then
        echo "✗ $output (HTTP $http_code)"
        rm -f "$temp_file"
        return 1
    fi

    # Check it is not a disguised 404 page
    if head -1 "$temp_file" | grep -qE "^404|^<!DOCTYPE|^<html"; then
        echo "✗ $output (invalid content)"
        rm -f "$temp_file"
        return 1
    fi

    # Check the file is not empty
    if [ ! -s "$temp_file" ]; then
        echo "✗ $output (empty)"
        rm -f "$temp_file"
        return 1
    fi

    # All OK, move the file
    mv "$temp_file" "$output"
    echo "✓ $output"
    return 0
}
```

---

## Phase 5.0: Synthesize (Apply Updates)

### 5.1: DevContainer Sync (from devcontainer-template)

**IMPORTANT**: Use `safe_download` for each file.

#### Hooks (scripts)

```bash
BASE="https://raw.githubusercontent.com/kodflow/devcontainer-template/main"
API="https://api.github.com/repos/kodflow/devcontainer-template/contents"

# Discover and download scripts via API (zsh-compatible)
curl -sL "$API/.devcontainer/images/.claude/scripts" | jq -r '.[].name' | grep '\.sh$' \
| while IFS= read -r script; do
    [ -z "$script" ] && continue
    safe_download \
        "$BASE/.devcontainer/images/.claude/scripts/$script" \
        ".devcontainer/images/.claude/scripts/$script" \
    && chmod +x ".devcontainer/images/.claude/scripts/$script"
done
```

#### Commands

```bash
# Discover and download commands via API (zsh-compatible)
curl -sL "$API/.devcontainer/images/.claude/commands" | jq -r '.[].name' | grep '\.md$' \
| while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    safe_download \
        "$BASE/.devcontainer/images/.claude/commands/$cmd" \
        ".devcontainer/images/.claude/commands/$cmd"
done
```

#### Agents

```bash
# Discover and download agents via API (zsh-compatible)
mkdir -p ".devcontainer/images/.claude/agents"
curl -sL "$API/.devcontainer/images/.claude/agents" | jq -r '.[].name' | grep '\.md$' \
| while IFS= read -r agent; do
    [ -z "$agent" ] && continue
    safe_download \
        "$BASE/.devcontainer/images/.claude/agents/$agent" \
        ".devcontainer/images/.claude/agents/$agent"
done
```

#### Lifecycle Hooks

```bash
# Discover and download lifecycle hooks via API (zsh-compatible)
mkdir -p ".devcontainer/hooks/lifecycle"
curl -sL "$API/.devcontainer/hooks/lifecycle" | jq -r '.[].name' | grep '\.sh$' \
| while IFS= read -r hook; do
    [ -z "$hook" ] && continue
    safe_download \
        "$BASE/.devcontainer/hooks/lifecycle/$hook" \
        ".devcontainer/hooks/lifecycle/$hook" \
    && chmod +x ".devcontainer/hooks/lifecycle/$hook"
done
```

#### Image-Embedded Hooks

```bash
# Discover image hooks via API (recursive: shared/ + lifecycle/)
mkdir -p ".devcontainer/images/hooks/shared" ".devcontainer/images/hooks/lifecycle"

# shared/utils.sh
safe_download \
    "$BASE/.devcontainer/images/hooks/shared/utils.sh" \
    ".devcontainer/images/hooks/shared/utils.sh" \
&& chmod +x ".devcontainer/images/hooks/shared/utils.sh"

# lifecycle hooks (zsh-compatible)
curl -sL "$API/.devcontainer/images/hooks/lifecycle" | jq -r '.[].name' | grep '\.sh$' \
| while IFS= read -r hook; do
    [ -z "$hook" ] && continue
    safe_download \
        "$BASE/.devcontainer/images/hooks/lifecycle/$hook" \
        ".devcontainer/images/hooks/lifecycle/$hook" \
    && chmod +x ".devcontainer/images/hooks/lifecycle/$hook"
done
```

#### Shared Utils (workspace copy for initialize.sh)

```bash
# Update workspace utils.sh (needed by initialize.sh on host)
safe_download \
    "$BASE/.devcontainer/hooks/shared/utils.sh" \
    ".devcontainer/hooks/shared/utils.sh"
```

#### Migration: Old Full Hooks → Delegation Stubs

```bash
# Detect old full hooks (hooks without "Delegation stub" marker) and replace with stubs
# Note: literal list works in zsh, no variable expansion needed
for hook in onCreate postCreate postStart postAttach updateContent; do
    hook_file=".devcontainer/hooks/lifecycle/${hook}.sh"
    if [ -f "$hook_file" ] && ! grep -q "Delegation stub" "$hook_file"; then
        echo "  Migrating ${hook}.sh to delegation stub..."
        safe_download \
            "$BASE/.devcontainer/hooks/lifecycle/${hook}.sh" \
            "$hook_file" \
        && chmod +x "$hook_file"
    fi
done
```

#### Config Files (p10k, settings, compose, grepai)

```bash
# p10k
safe_download \
    "$BASE/.devcontainer/images/.p10k.zsh" \
    ".devcontainer/images/.p10k.zsh"

# settings.json
safe_download \
    "$BASE/.devcontainer/images/.claude/settings.json" \
    ".devcontainer/images/.claude/settings.json"

# docker-compose.yml (update devcontainer service, PRESERVE custom services)
# Note: Uses mikefarah/yq (Go version) - simpler syntax with -i for in-place
# Strategy: Start fresh from template, merge back custom services
# Note: Ollama runs on HOST (installed via initialize.sh), not in container
update_compose_services() {
    local compose_file=".devcontainer/docker-compose.yml"
    local temp_template=$(mktemp --suffix=.yaml)
    local temp_custom=$(mktemp --suffix=.yaml)
    local backup_file="${compose_file}.backup"

    # Download template
    if ! curl -sL -o "$temp_template" "$BASE/.devcontainer/docker-compose.yml"; then
        echo "  ✗ Failed to download template"
        rm -f "$temp_template"
        return 1
    fi

    # Validate downloaded template is not empty and contains expected content
    if [ ! -s "$temp_template" ] || ! grep -q "^services:" "$temp_template"; then
        echo "  ✗ Downloaded template is empty or invalid (check network/rate limit)"
        rm -f "$temp_template"
        return 1
    fi

    # Backup original
    cp "$compose_file" "$backup_file"

    # Extract custom services (anything that's NOT devcontainer)
    yq '.services | to_entries | map(select(.key != "devcontainer")) | from_entries' "$compose_file" > "$temp_custom"

    # Start fresh from template (devcontainer service)
    cp "$temp_template" "$compose_file"

    # Merge back custom services if any exist
    if [ -s "$temp_custom" ] && [ "$(yq '. | length' "$temp_custom")" != "0" ]; then
        yq -i ".services *= load(\"$temp_custom\")" "$compose_file"
        echo "    - Preserved custom services"
    fi

    # Cleanup temp files
    rm -f "$temp_template" "$temp_custom"

    # Verify file is not empty and contains required structure
    if [ ! -s "$compose_file" ] || ! grep -q "^services:" "$compose_file"; then
        # File is empty or missing services - restore backup
        mv "$backup_file" "$compose_file"
        echo "  ✗ Result file is empty or invalid, restored backup"
        return 1
    fi

    # Verify YAML is valid and has expected content
    if yq '.services.devcontainer' "$compose_file" > /dev/null 2>&1; then
        rm -f "$backup_file"
        echo "  ✓ docker-compose.yml updated"
        echo "    - REPLACED: devcontainer from template"
        echo "    - PRESERVED: custom services (if any)"
        return 0
    else
        # Restore backup on failure
        mv "$backup_file" "$compose_file"
        echo "  ✗ YAML validation failed (missing devcontainer service), restored backup"
        return 1
    fi
}

if [ ! -f ".devcontainer/docker-compose.yml" ]; then
    # No file exists - download full template
    safe_download \
        "$BASE/.devcontainer/docker-compose.yml" \
        ".devcontainer/docker-compose.yml"
    echo "  ✓ docker-compose.yml created from template"
else
    # File exists - update devcontainer service
    echo "  Updating devcontainer service..."
    update_compose_services
fi

# grepai config (optimized with bge-m3)
safe_download \
    "$BASE/.devcontainer/images/grepai.config.yaml" \
    ".devcontainer/images/grepai.config.yaml"
```

### 5.2: Infrastructure Sync (from infrastructure-template, if detected)

**Condition:** Only runs when `PROFILE == "infrastructure"`.

**Strategy:** Download each file from the infrastructure template using the Git Trees
discovery (Phase 3.0). Protected paths are NEVER overwritten.

```bash
# Infrastructure sync (only if infrastructure profile detected)
sync_infrastructure() {
    if [ "$PROFILE" != "infrastructure" ]; then
        return 0
    fi

    echo ""
    echo "═══════════════════════════════════════════════"
    echo "  Phase 5.2: Infrastructure Sync"
    echo "═══════════════════════════════════════════════"

    local infra_count=0
    local infra_skip=0

    # Protected paths - NEVER overwritten
    local protected="inventory/ terragrunt.hcl .env CLAUDE.md AGENTS.md README.md Makefile docs/"

    # Download infrastructure files discovered in Phase 3.0
    echo "$INFRA_FILES" | while IFS= read -r filepath; do
        [ -z "$filepath" ] && continue

        # Check against protected paths
        local is_protected=false
        for p in $protected; do
            case "$filepath" in
                ${p}*) is_protected=true; break ;;
            esac
        done

        if [ "$is_protected" = true ]; then
            infra_skip=$((infra_skip + 1))
            continue
        fi

        # Download and write file
        if safe_download "$INFRA_BASE/$filepath" "$filepath"; then
            # Make scripts executable
            case "$filepath" in
                *.sh) chmod +x "$filepath" ;;
            esac
            infra_count=$((infra_count + 1))
        fi
    done

    echo ""
    echo "  Infrastructure sync: $infra_count files updated, $infra_skip protected"
}

sync_infrastructure
```

**Infrastructure components synced:**

| Component | Source path | Description |
|-----------|------------|-------------|
| Modules | `modules/**` | Terraform modules (cloud, services, base) |
| Stacks | `stacks/**` | Terragrunt stacks (management, edge, compute, vpn) |
| Ansible | `ansible/**` | Roles and playbooks |
| Packer | `packer/**` | Machine images per provider |
| CI | `ci/**` | GitHub Actions + GitLab CI pipelines |
| Tests | `tests/**` | Terratest + Molecule tests |

### 5.3: Cleanup deprecated files

```bash
# Remove deprecated configuration files
[ -f ".coderabbit.yaml" ] && rm -f ".coderabbit.yaml" \
    && echo "Removed deprecated .coderabbit.yaml"
```

### 5.4: Update version files

```bash
# DevContainer version (always)
DC_COMMIT=$(curl -sL "https://api.github.com/repos/kodflow/devcontainer-template/commits/main" | jq -r '.sha[:7]')
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"commit\": \"$DC_COMMIT\", \"updated\": \"$DATE\"}" > .devcontainer/.template-version

# Infrastructure version (only if infrastructure profile)
if [ "$PROFILE" = "infrastructure" ]; then
    INFRA_COMMIT=$(curl -sL "https://api.github.com/repos/kodflow/infrastructure-template/commits/main" | jq -r '.sha[:7]')
    echo "{\"commit\": \"$INFRA_COMMIT\", \"updated\": \"$DATE\", \"source\": \"kodflow/infrastructure-template\"}" > .infra-template-version
fi
```

### 5.5: Consolidated report

**Final output (infrastructure profile):**

```
═══════════════════════════════════════════════
  ✓ Update complete
═══════════════════════════════════════════════

  Profile : infrastructure (dual-source)

  Source 1: kodflow/devcontainer-template
  Version : def5678 (2024-01-20)

  DevContainer components:
    ✓ hooks        (10 scripts)
    ✓ commands     (10 commands)
    ✓ agents       (35 agents)
    ✓ lifecycle    (6 delegation stubs)
    ✓ image-hooks  (6 image-embedded hooks)
    ✓ shared-utils (1 file)
    ✓ p10k         (1 file)
    ✓ settings     (1 file)
    ✓ compose      (devcontainer service updated)
    ✓ grepai       (1 file - bge-m3 config)
    ✓ user-hooks   (synchronized with template)
    ✓ validation   (all scripts exist)

  Source 2: kodflow/infrastructure-template
  Version : ghi9012 (2024-01-18)

  Infrastructure components:
    ✓ modules      (42 files)
    ✓ stacks       (15 files)
    ✓ ansible      (28 files)
    ✓ packer       (8 files)
    ✓ ci           (12 files)
    ✓ tests        (18 files)
    ⊘ Protected    (inventory/, terragrunt.hcl, docs/, ...)

  Grepai config:
    provider: ollama
    model: bge-m3
    endpoint: host.docker.internal:11434 (GPU-accelerated)

  Cleanup:
    ✓ .coderabbit.yaml removed (if existed)

  Note: Restart terminal to apply p10k changes.

═══════════════════════════════════════════════
```

**Final output (devcontainer profile):**

```
═══════════════════════════════════════════════
  ✓ Update complete
═══════════════════════════════════════════════

  Profile : devcontainer (single source)

  Source: kodflow/devcontainer-template
  Version : def5678 (2024-01-20)

  Updated components:
    ✓ hooks        (10 scripts)
    ✓ commands     (10 commands)
    ✓ agents       (35 agents)
    ✓ lifecycle    (6 delegation stubs)
    ✓ image-hooks  (6 image-embedded hooks)
    ✓ shared-utils (1 file)
    ✓ p10k         (1 file)
    ✓ settings     (1 file)
    ✓ compose      (devcontainer service updated)
    ✓ grepai       (1 file - bge-m3 config)
    ✓ user-hooks   (synchronized with template)
    ✓ validation   (all scripts exist)

  Grepai config:
    provider: ollama
    model: bge-m3
    endpoint: host.docker.internal:11434 (GPU-accelerated)

  Cleanup:
    ✓ .coderabbit.yaml removed (if existed)

  Note: Restart terminal to apply p10k changes.

═══════════════════════════════════════════════
```

---

## Phase 6.0: Hook Synchronization

**Goal:** Synchronize hooks from `~/.claude/settings.json` with the template.

**Problem solved:** Users with an older `settings.json` may have
references to obsolete scripts (bash-validate.sh, phase-validate.sh, etc.)
because `postStart.sh` only copies `settings.json` if it does not exist.

```yaml
hook_sync_workflow:
  1_backup:
    action: "Backup user settings.json"
    command: "cp ~/.claude/settings.json ~/.claude/settings.json.backup"

  2_merge_hooks:
    action: "Replace the hooks section with the template"
    strategy: "REPLACE (not merge) - the template is the source of truth"
    tool: jq
    preserves:
      - permissions
      - model
      - env
      - statusLine
      - disabledMcpjsonServers

  3_restore_on_failure:
    action: "Restore backup if merge fails"
```

**Implementation:**

```bash
sync_user_hooks() {
    local user_settings="$HOME/.claude/settings.json"
    local template_settings=".devcontainer/images/.claude/settings.json"

    if [ ! -f "$user_settings" ]; then
        echo "  ⚠ No user settings.json, skipping hook sync"
        return 0
    fi

    if [ ! -f "$template_settings" ]; then
        echo "  ✗ Template settings.json not found"
        return 1
    fi

    echo "  Synchronizing user hooks with template..."

    # Backup
    cp "$user_settings" "${user_settings}.backup"

    # Replace hooks section only (preserve all other settings)
    if jq --slurpfile tpl "$template_settings" '.hooks = $tpl[0].hooks' \
       "$user_settings" > "${user_settings}.tmp"; then

        # Validate JSON
        if jq empty "${user_settings}.tmp" 2>/dev/null; then
            mv "${user_settings}.tmp" "$user_settings"
            rm -f "${user_settings}.backup"
            echo "  ✓ User hooks synchronized with template"
            return 0
        else
            mv "${user_settings}.backup" "$user_settings"
            rm -f "${user_settings}.tmp"
            echo "  ✗ Hook merge produced invalid JSON, restored backup"
            return 1
        fi
    else
        mv "${user_settings}.backup" "$user_settings"
        echo "  ✗ Hook merge failed, restored backup"
        return 1
    fi
}
```

---

## Phase 7.0: Script Validation

**Goal:** Validate that all scripts referenced in hooks exist.

```yaml
validate_workflow:
  1_extract:
    action: "Extract all script paths from hooks"
    tool: jq
    pattern: ".hooks | .. | .command? // empty"

  2_verify:
    action: "Verify that each script exists"
    for_each: script_path
    check: "[ -f $script_path ]"

  3_report:
    on_missing: "List missing scripts with fix suggestion"
    on_success: "All scripts validated"
```

**Implementation:**

```bash
validate_hook_scripts() {
    local settings_file="$HOME/.claude/settings.json"
    local scripts_dir="$HOME/.claude/scripts"
    local missing_count=0

    if [ ! -f "$settings_file" ]; then
        echo "  ⚠ No settings.json to validate"
        return 0
    fi

    # Extract all script paths from hooks
    local scripts
    scripts=$(jq -r '.hooks | .. | .command? // empty' "$settings_file" 2>/dev/null \
        | grep -oE '/home/vscode/.claude/scripts/[^ "]+' \
        | sed 's/ .*//' \
        | sort -u)

    if [ -z "$scripts" ]; then
        echo "  ⚠ No hook scripts found in settings.json"
        return 0
    fi

    echo "  Validating hook scripts..."

    # Use while read for zsh compatibility (for x in $VAR breaks in zsh)
    echo "$scripts" | while IFS= read -r script_path; do
        [ -z "$script_path" ] && continue
        local script_name=$(basename "$script_path")

        if [ -f "$script_path" ]; then
            echo "    ✓ $script_name"
        else
            echo "    ✗ $script_name (MISSING)"
            missing_count=$((missing_count + 1))
        fi
    done

    if [ $missing_count -gt 0 ]; then
        echo ""
        echo "  ⚠ $missing_count missing script(s) detected!"
        echo "  → Run: /update --component hooks"
        return 1
    fi

    echo "  ✓ All hook scripts validated"
    return 0
}
```

---

## Guardrails (ABSOLUTE)

| Action | Status | Reason |
|--------|--------|--------|
| Use hardcoded lists | **FORBIDDEN** | API-FIRST MANDATORY |
| Write without validation | **FORBIDDEN** | Corruption risk |
| Skip HTTP verification | **FORBIDDEN** | 404 files possible |
| Non-official source | **FORBIDDEN** | Security |
| Hook sync without backup | **FORBIDDEN** | Always backup first |
| Delete user settings | **FORBIDDEN** | Only merge hooks |
| Skip script validation | **FORBIDDEN** | Error detection MANDATORY |
| `for x in $VAR` pattern | **FORBIDDEN** | Breaks in zsh ($SHELL=zsh) |
| Inline execution without bash | **FORBIDDEN** | Always `bash /tmp/script.sh` |
| Overwrite protected paths | **FORBIDDEN** | inventory/, terragrunt.hcl, .env*, docs/, CLAUDE.md, AGENTS.md, README.md, Makefile |
| Infra sync without profile check | **FORBIDDEN** | Must detect profile first |

---

## Affected files

**Updated by /update (DevContainer sync — always):**
```
.devcontainer/
├── docker-compose.yml            # Update devcontainer service
├── hooks/
│   ├── lifecycle/*.sh            # Delegation stubs
│   └── shared/utils.sh          # Shared utilities (host)
├── images/
│   ├── .p10k.zsh
│   ├── grepai.config.yaml       # grepai config (provider, model)
│   ├── hooks/                    # Image-embedded hooks (real logic)
│   │   ├── shared/utils.sh
│   │   └── lifecycle/*.sh
│   └── .claude/
│       ├── agents/*.md
│       ├── commands/*.md
│       ├── scripts/*.sh
│       └── settings.json
└── .template-version
```

**Updated by /update (Infrastructure sync — infrastructure profile only):**
```
modules/                          # Terraform modules
├── cloud/                        #   compute, network, storage, dns
├── services/                     #   vault, consul, nomad, garage, ldap, etc.
└── base/                         #   firewall, ssh
stacks/                           # Terragrunt stacks
├── management/                   #   vault+consul+nomad+garage+ldap+dns
├── edge/                         #   cloudflare+dns+ssl
├── compute/                      #   network+compute+firewall
└── vpn/                          #   openvpn+wireguard+pptp
ansible/                          # Roles and playbooks
packer/                           # Machine images
ci/                               # GitHub Actions + GitLab CI
tests/                            # Terratest + Molecule
.infra-template-version           # Infrastructure version tracker
```

**In the Docker image (restored at startup):**
```
/etc/grepai/config.yaml            # GrepAI config template
/etc/mcp/mcp.json.tpl              # MCP template
/etc/claude-defaults/*             # Claude defaults
```

**NEVER modified by /update:**
```
.devcontainer/
├── devcontainer.json      # Project config (customizations)
└── Dockerfile             # Image customizations

inventory/                 # Product-specific configuration
terragrunt.hcl             # Root config (product-specific)
.env*                      # Secrets and environment variables
CLAUDE.md                  # Project documentation
AGENTS.md                  # Project agents
README.md                  # Project readme
Makefile                   # Project build
docs/                      # Project documentation
```

---

## Complete script (reference)

**IMPORTANT: This script uses `#!/bin/bash`. Always write to a temp file and execute with `bash`:**
```bash
cat > /tmp/update-devcontainer.sh << 'SCRIPT'
# ... (script below) ...
SCRIPT
bash /tmp/update-devcontainer.sh && rm -f /tmp/update-devcontainer.sh
```

```bash
#!/bin/bash
# /update implementation - API-FIRST with validation + Environment Detection + Profile Detection
# Supports dual-source sync: devcontainer-template + infrastructure-template
# NOTE: Must be executed with bash (not zsh) due to word splitting in for loops.
# If running from Claude Code (zsh), write to temp file first: bash /tmp/script.sh

set -uo pipefail
set +H 2>/dev/null || true  # Disable bash history expansion (! in YAML causes errors)

# DevContainer source (always)
BASE="https://raw.githubusercontent.com/kodflow/devcontainer-template/main"
API="https://api.github.com/repos/kodflow/devcontainer-template/contents"

# Infrastructure source (set by detect_template_profile if needed)
PROFILE="devcontainer"
INFRA_REPO=""
INFRA_BASE=""
INFRA_TREES=""
INFRA_FILES=""

# Environment detection function (Phase 1.0)
detect_context() {
    # Check if running inside container
    if [ -f /.dockerenv ]; then
        CONTEXT="container"
        UPDATE_TARGET="/workspace/.devcontainer/images/.claude"
        echo "Detected: Container environment"
    else
        CONTEXT="host"
        UPDATE_TARGET="$HOME/.claude"
        echo "Detected: Host machine"
    fi

    # Additional checks
    if [ -n "${DEVCONTAINER:-}" ]; then
        echo "  (DevContainer detected via DEVCONTAINER env var)"
    fi

    echo "Update target: $UPDATE_TARGET"
    echo "Mode: $CONTEXT"
}

# Template profile detection function (Phase 1.5)
detect_template_profile() {
    if [ -d "modules" ] || [ -d "stacks" ] || [ -d "ansible" ]; then
        PROFILE="infrastructure"
        INFRA_REPO="kodflow/infrastructure-template"
        INFRA_BASE="https://raw.githubusercontent.com/${INFRA_REPO}/main"
        INFRA_TREES="https://api.github.com/repos/${INFRA_REPO}/git/trees/main?recursive=1"
    else
        PROFILE="devcontainer"
        INFRA_REPO=""
    fi

    echo ""
    echo "═══════════════════════════════════════════════"
    echo "  Template Profile Detection"
    echo "═══════════════════════════════════════════════"
    echo "  Profile  : $PROFILE"
    echo "  Sources  :"
    echo "    1. kodflow/devcontainer-template (core)"
    if [ "$PROFILE" = "infrastructure" ]; then
        echo "    2. kodflow/infrastructure-template (infra)"
    fi
    echo "═══════════════════════════════════════════════"
}

# Infrastructure file discovery via Git Trees API (Phase 3.0 extension)
discover_infra_files() {
    if [ "$PROFILE" != "infrastructure" ]; then
        return 0
    fi

    echo ""
    echo "Discovering infrastructure files..."
    INFRA_FILES=$(curl -sL "$INFRA_TREES" \
        | jq -r '.tree[] | select(.type == "blob") | .path' \
        | grep -E '^(modules|stacks|ansible|packer|ci|tests)/' || true)

    if [ -z "$INFRA_FILES" ]; then
        echo "  ⚠ No infrastructure files found in template"
        return 0
    fi

    local count=$(echo "$INFRA_FILES" | wc -l | tr -d ' ')
    echo "  Discovered $count infrastructure files"
}

# Infrastructure sync function (Phase 5.2)
sync_infrastructure() {
    if [ "$PROFILE" != "infrastructure" ]; then
        return 0
    fi

    if [ -z "$INFRA_FILES" ]; then
        echo "  ⚠ No infrastructure files to sync"
        return 0
    fi

    echo ""
    echo "═══════════════════════════════════════════════"
    echo "  Phase 5.2: Infrastructure Sync"
    echo "═══════════════════════════════════════════════"

    local infra_count=0
    local infra_skip=0

    while IFS= read -r filepath; do
        [ -z "$filepath" ] && continue

        # Check against protected paths
        local is_protected=false
        case "$filepath" in
            inventory/*|terragrunt.hcl|.env*|CLAUDE.md|AGENTS.md|README.md|Makefile|docs/*)
                is_protected=true ;;
        esac

        if [ "$is_protected" = true ]; then
            infra_skip=$((infra_skip + 1))
            continue
        fi

        # Download and write file
        if safe_download "$INFRA_BASE/$filepath" "$filepath"; then
            case "$filepath" in
                *.sh) chmod +x "$filepath" ;;
            esac
            infra_count=$((infra_count + 1))
        fi
    done <<< "$INFRA_FILES"

    echo ""
    echo "  Infrastructure sync: $infra_count files updated, $infra_skip protected"
}

# Safe download function
safe_download() {
    local url="$1"
    local output="$2"
    local temp_file=$(mktemp)

    http_code=$(curl -sL -w "%{http_code}" -o "$temp_file" "$url")

    if [ "$http_code" != "200" ]; then
        echo "✗ $(basename "$output") (HTTP $http_code)"
        rm -f "$temp_file"
        return 1
    fi

    if head -1 "$temp_file" | grep -qE "^404|^<!DOCTYPE|^<html"; then
        echo "✗ $(basename "$output") (invalid content)"
        rm -f "$temp_file"
        return 1
    fi

    if [ ! -s "$temp_file" ]; then
        echo "✗ $(basename "$output") (empty)"
        rm -f "$temp_file"
        return 1
    fi

    mkdir -p "$(dirname "$output")"
    mv "$temp_file" "$output"
    echo "✓ $(basename "$output")"
    return 0
}

# Hook synchronization function (Phase 5)
sync_user_hooks() {
    local user_settings="$HOME/.claude/settings.json"
    local template_settings=".devcontainer/images/.claude/settings.json"

    if [ ! -f "$user_settings" ]; then
        echo "  ⚠ No user settings.json, skipping hook sync"
        return 0
    fi

    if [ ! -f "$template_settings" ]; then
        echo "  ✗ Template settings.json not found"
        return 1
    fi

    echo "  Synchronizing user hooks with template..."
    cp "$user_settings" "${user_settings}.backup"

    if jq --slurpfile tpl "$template_settings" '.hooks = $tpl[0].hooks' \
       "$user_settings" > "${user_settings}.tmp"; then
        if jq empty "${user_settings}.tmp" 2>/dev/null; then
            mv "${user_settings}.tmp" "$user_settings"
            rm -f "${user_settings}.backup"
            echo "  ✓ User hooks synchronized"
            return 0
        else
            mv "${user_settings}.backup" "$user_settings"
            rm -f "${user_settings}.tmp"
            echo "  ✗ Invalid JSON, restored backup"
            return 1
        fi
    else
        mv "${user_settings}.backup" "$user_settings"
        echo "  ✗ Hook merge failed, restored backup"
        return 1
    fi
}

# Script validation function (Phase 6)
validate_hook_scripts() {
    local settings_file="$HOME/.claude/settings.json"
    local missing_count=0

    if [ ! -f "$settings_file" ]; then
        echo "  ⚠ No settings.json to validate"
        return 0
    fi

    local scripts
    scripts=$(jq -r '.hooks | .. | .command? // empty' "$settings_file" 2>/dev/null \
        | grep -oE '/home/vscode/.claude/scripts/[^ "]+' \
        | sed 's/ .*//' | sort -u)

    if [ -z "$scripts" ]; then
        echo "  ⚠ No hook scripts found"
        return 0
    fi

    echo "  Validating hook scripts..."
    while IFS= read -r script_path; do
        [ -z "$script_path" ] && continue
        local script_name=$(basename "$script_path")
        if [ -f "$script_path" ]; then
            echo "    ✓ $script_name"
        else
            echo "    ✗ $script_name (MISSING)"
            missing_count=$((missing_count + 1))
        fi
    done <<< "$scripts"

    if [ $missing_count -gt 0 ]; then
        echo "  ⚠ $missing_count missing script(s)!"
        echo "  → Run: /update --component hooks"
        return 1
    fi

    echo "  ✓ All scripts validated"
    return 0
}

echo "═══════════════════════════════════════════════"
echo "  /update - Template Environment Update"
echo "═══════════════════════════════════════════════"
echo ""

# Phase 1.0: Environment Detection
detect_context

# Phase 1.5: Template Profile Detection
detect_template_profile

# Phase 3.0 (infra extension): Discover infrastructure files
discover_infra_files

echo ""

# Phase 5.1: DevContainer Sync
echo "═══════════════════════════════════════════════"
echo "  Phase 5.1: DevContainer Sync"
echo "═══════════════════════════════════════════════"

# Hooks
echo "Updating hooks..."
hook_count=0
while IFS= read -r script; do
    [ -z "$script" ] && continue
    if safe_download "$BASE/.devcontainer/images/.claude/scripts/$script" \
                     "$UPDATE_TARGET/scripts/$script"; then
        chmod +x "$UPDATE_TARGET/scripts/$script"
        hook_count=$((hook_count + 1))
    fi
done < <(curl -sL "$API/.devcontainer/images/.claude/scripts" | jq -r '.[].name' | grep '\.sh$')
echo "  ($hook_count scripts)"

# Commands
echo ""
echo "Updating commands..."
cmd_count=0
while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    if safe_download "$BASE/.devcontainer/images/.claude/commands/$cmd" \
                     "$UPDATE_TARGET/commands/$cmd"; then
        cmd_count=$((cmd_count + 1))
    fi
done < <(curl -sL "$API/.devcontainer/images/.claude/commands" | jq -r '.[].name' | grep '\.md$')
echo "  ($cmd_count commands)"

# Agents
echo ""
echo "Updating agents..."
mkdir -p "$UPDATE_TARGET/agents"
agent_count=0
while IFS= read -r agent; do
    [ -z "$agent" ] && continue
    if safe_download "$BASE/.devcontainer/images/.claude/agents/$agent" \
                     "$UPDATE_TARGET/agents/$agent"; then
        agent_count=$((agent_count + 1))
    fi
done < <(curl -sL "$API/.devcontainer/images/.claude/agents" | jq -r '.[].name' | grep '\.md$')
echo "  ($agent_count agents)"

# Lifecycle stubs (only in container mode - skip on host)
if [ "$CONTEXT" = "container" ]; then
    echo ""
    echo "Updating lifecycle hooks (delegation stubs)..."
    mkdir -p ".devcontainer/hooks/lifecycle"
    lifecycle_count=0
    while IFS= read -r hook; do
        [ -z "$hook" ] && continue
        if safe_download "$BASE/.devcontainer/hooks/lifecycle/$hook" \
                         ".devcontainer/hooks/lifecycle/$hook"; then
            chmod +x ".devcontainer/hooks/lifecycle/$hook"
            lifecycle_count=$((lifecycle_count + 1))
        fi
    done < <(curl -sL "$API/.devcontainer/hooks/lifecycle" | jq -r '.[].name' | grep '\.sh$')
    echo "  ($lifecycle_count stubs)"

    # Image-embedded hooks (real logic)
    echo ""
    echo "Updating image-embedded hooks..."
    mkdir -p ".devcontainer/images/hooks/shared" ".devcontainer/images/hooks/lifecycle"
    safe_download "$BASE/.devcontainer/images/hooks/shared/utils.sh" \
                  ".devcontainer/images/hooks/shared/utils.sh" \
    && chmod +x ".devcontainer/images/hooks/shared/utils.sh"
    while IFS= read -r hook; do
        [ -z "$hook" ] && continue
        safe_download "$BASE/.devcontainer/images/hooks/lifecycle/$hook" \
                      ".devcontainer/images/hooks/lifecycle/$hook" \
        && chmod +x ".devcontainer/images/hooks/lifecycle/$hook"
    done < <(curl -sL "$API/.devcontainer/images/hooks/lifecycle" | jq -r '.[].name' | grep '\.sh$')

    # Shared utils (workspace copy for initialize.sh on host)
    echo ""
    echo "Updating shared utilities..."
    safe_download "$BASE/.devcontainer/hooks/shared/utils.sh" \
                  ".devcontainer/hooks/shared/utils.sh"

    # Migration: detect old full hooks and replace with stubs
    for h in onCreate postCreate postStart postAttach updateContent; do
        hook_file=".devcontainer/hooks/lifecycle/${h}.sh"
        if [ -f "$hook_file" ] && ! grep -q "Delegation stub" "$hook_file"; then
            echo "  Migrating ${h}.sh to delegation stub..."
            safe_download "$BASE/.devcontainer/hooks/lifecycle/${h}.sh" "$hook_file" \
            && chmod +x "$hook_file"
        fi
    done
fi

# Config files
echo ""
echo "Updating config files..."
if [ "$CONTEXT" = "container" ]; then
    safe_download "$BASE/.devcontainer/images/.p10k.zsh" ".devcontainer/images/.p10k.zsh"
fi
safe_download "$BASE/.devcontainer/images/.claude/settings.json" "$UPDATE_TARGET/settings.json"

# Docker compose (only in container mode - not applicable on host)
if [ "$CONTEXT" = "container" ]; then
    # Note: Uses mikefarah/yq (Go version) - simpler syntax with -i for in-place
    # Ollama runs on HOST (installed via initialize.sh), not in container
    echo ""
    echo "Updating docker-compose.yml..."

    update_compose_services() {
    local compose_file=".devcontainer/docker-compose.yml"
    local temp_template=$(mktemp --suffix=.yaml)
    local temp_custom=$(mktemp --suffix=.yaml)
    local backup_file="${compose_file}.backup"

    # Download template
    if ! curl -sL -o "$temp_template" "$BASE/.devcontainer/docker-compose.yml"; then
        echo "  ✗ Failed to download template"
        rm -f "$temp_template"
        return 1
    fi

    # Validate downloaded template is not empty and contains expected content
    if [ ! -s "$temp_template" ] || ! grep -q "^services:" "$temp_template"; then
        echo "  ✗ Downloaded template is empty or invalid (check network/rate limit)"
        rm -f "$temp_template"
        return 1
    fi

    # Backup original
    cp "$compose_file" "$backup_file"

    # Extract custom services (anything that's NOT devcontainer)
    yq '.services | to_entries | map(select(.key != "devcontainer")) | from_entries' "$compose_file" > "$temp_custom"

    # Extract custom volumes (anything that's NOT in template)
    local template_volumes=$(yq '.volumes | keys | .[]' "$temp_template" 2>/dev/null | tr '\n' '|')

    # Start fresh from template (devcontainer service)
    cp "$temp_template" "$compose_file"

    # Merge back custom services if any exist
    if [ -s "$temp_custom" ] && [ "$(yq '. | length' "$temp_custom")" != "0" ]; then
        yq -i ".services *= load(\"$temp_custom\")" "$compose_file"
        echo "    - Preserved custom services"
    fi

    # Cleanup temp files
    rm -f "$temp_template" "$temp_custom"

    # Verify file is not empty and contains required structure
    if [ ! -s "$compose_file" ] || ! grep -q "^services:" "$compose_file"; then
        # File is empty or missing services - restore backup
        mv "$backup_file" "$compose_file"
        echo "  ✗ Result file is empty or invalid, restored backup"
        return 1
    fi

    # Verify YAML is valid and has expected content
    if yq '.services.devcontainer' "$compose_file" > /dev/null 2>&1; then
        rm -f "$backup_file"
        echo "  ✓ devcontainer service updated"
        return 0
    else
        mv "$backup_file" "$compose_file"
        echo "  ✗ YAML validation failed (missing devcontainer service), restored backup"
        return 1
    fi
}

    if [ ! -f ".devcontainer/docker-compose.yml" ]; then
        echo "  No docker-compose.yml found, downloading template..."
        safe_download "$BASE/.devcontainer/docker-compose.yml" ".devcontainer/docker-compose.yml"
    else
        echo "  Updating devcontainer service..."
        update_compose_services
    fi

    # Grepai config
    echo ""
    echo "Updating grepai config..."
    safe_download "$BASE/.devcontainer/images/grepai.config.yaml" ".devcontainer/images/grepai.config.yaml"
fi  # End container-only updates

# Phase 5.2: Infrastructure Sync (if applicable)
sync_infrastructure

# Phase 6.0: Synchronize user hooks (both container and host)
echo ""
echo "Phase 6.0: Synchronizing user hooks..."
sync_user_hooks

# Phase 7.0: Validate hook scripts
echo ""
echo "Phase 7.0: Validating hook scripts..."
validate_hook_scripts

# Version files
DC_COMMIT=$(curl -sL "https://api.github.com/repos/kodflow/devcontainer-template/commits/main" | jq -r '.sha[:7]')
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ "$CONTEXT" = "container" ]; then
    echo "{\"commit\": \"$DC_COMMIT\", \"updated\": \"$DATE\"}" > .devcontainer/.template-version
else
    echo "{\"commit\": \"$DC_COMMIT\", \"updated\": \"$DATE\"}" > "$UPDATE_TARGET/.template-version"
fi

# Infrastructure version (only if infrastructure profile)
if [ "$PROFILE" = "infrastructure" ]; then
    INFRA_COMMIT=$(curl -sL "https://api.github.com/repos/${INFRA_REPO}/commits/main" | jq -r '.sha[:7]')
    echo "{\"commit\": \"$INFRA_COMMIT\", \"updated\": \"$DATE\", \"source\": \"${INFRA_REPO}\"}" > .infra-template-version
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "  ✓ Update complete"
echo "═══════════════════════════════════════════════"
echo "  Profile : $PROFILE"
echo "  Context : $CONTEXT"
echo "  Target  : $UPDATE_TARGET"
echo ""
echo "  Source 1: kodflow/devcontainer-template"
echo "  Version : $DC_COMMIT"
if [ "$PROFILE" = "infrastructure" ]; then
    echo ""
    echo "  Source 2: $INFRA_REPO"
    echo "  Version : $INFRA_COMMIT"
fi
echo "═══════════════════════════════════════════════"
```
