# Copilot Instructions for `intel-innersource/applications.ai.erag.infra-automation`

This guide enables AI coding agents to be productive in the Intel AI for Enterprise Inference automation codebase.

---

## Architecture & Major Components

- **Kubernetes-centric**: codebase targets deploying and managing AI inference clusters on Kubernetes, supporting both Intel Xeon and Gaudi hardware.
- **Key Components:**
  - `core/`: Main automation logic, including Ansible playbooks, Helm charts, and shell scripts.
  - `core/helm-charts/`: Helm charts for deploying APISIX, Keycloak, GenAI Gateway (LiteLLM + Langfuse), Observability, and more.
  - `core/scripts/`: Automation scripts for firmware, drivers, and cluster setup (see `firmware-update.sh` for robust, version-aware upgrades).
  - `docs/`: Deployment, configuration, and usage documentation.
  - `third_party/`: Vendor-specific integrations (e.g., IBM).
- **GenAI Gateway**: Combines LiteLLM and Langfuse for prompt routing, observability, and analytics. See `core/helm-charts/genai-gateway-trace` and Langfuse chart for configuration patterns.

---

## Developer Workflows

- **Cluster Deployment:**
  - Edit `inventory/hosts.yaml` and `core/inference-config.cfg` for your environment.
  - Deploy with:
    ```bash
    bash core/inference-stack-deploy.sh
    ```
- **Firmware/Driver Management:**
  - Use `core/scripts/firmware-update.sh <version>` for Gaudi nodes. Handles version checks, safe module reloads, and error resilience.
- **Playbooks:**
  - Ansible playbooks in `core/playbooks/` automate component deployment.
  - Example: `deploy-genai-gateway.yml` for GenAI Gateway.
- **Helm Charts:**
  - Each major service has a chart in `core/helm-charts/`.
  - Values files and chart README docs provide configuration options.

---

## Project Conventions

- **Shell Scripts:**
  - Use `set -euo pipefail` for safety.
  - Modularize with functions, check all exit codes, and document usage.
- **Configuration:**
  - All environment-specific data in config files, not hardcoded.
  - Secrets must be injected via environment variables or vaults.
- **Branching:**
  - Use descriptive feature branch names (e.g., `firmware-update-automation`).
  - PRs should link to relevant docs and describe automation flows.

---

## Integration & Patterns

- **External Integrations:**
  - IBM catalog support via `ibm_catalog.json`.
  - Keycloak for auth, APISIX for API gateway, Langfuse for LLM observability.
- **Cross-Component Communication:**
  - Services communicate via Kubernetes networking and API gateways.
  - Observability is enabled cluster-wide via Helm-deployed monitoring stacks.

---

## Examples

- Add a new model:
  - Update `core/inference-config.cfg` and redeploy with the stack script.
- Upgrade Gaudi firmware:
  - `sudo bash core/scripts/firmware-update.sh 1.21.1`
- Deploy GenAI Gateway:
  - `ansible-playbook core/playbooks/deploy-genai-gateway.yml`

---

For more, see `README.md`, `docs/`, and chart READMEs.
If any section is unclear or incomplete, please specify what needs improvement or more detail!
