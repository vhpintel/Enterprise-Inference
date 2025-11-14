# Enterprise Inference and RAG Deployment Guide

## Prerequisites

### System Requirements

- **Operating System**: Ubuntu 22.04
- **Hardware Requirements**:
  - Minimum 88 logical CPU cores
  - Minimum 250GB RAM
  - Minimum 200GB disk space (varies based on model size)
  - **Example Instance**: AWS r7i.24xlarge (4th Gen Intel® Xeon® Platinum 8488C)

### Additional Requirements

- **Hugging Face Model Access**: `casperhansen/llama-3-8b-instruct-awq`
- **SSL/TLS Certificate**: Obtain from a trusted Certificate Authority (CA)
- **Domain Configuration**: Registered domain with DNS records pointing to your production server or load balancer

---

## Deployment Steps

### Step 1: Deploy Enterprise Inference

1. **Clone the Enterprise Inference repository**:
   ```bash
   cd ~
   git clone https://github.com/opea-project/Enterprise-Inference.git
   cd Enterprise-Inference
   ```

2. **Configure inference settings**:
   ```bash
   cp -f docs/examples/single-node/inference-config.cfg core/inventory/inference-config.cfg
   ```
   
   Update `inference-config.cfg` with your values:
   - Copy `inference-config.cfg` to `inventory/inference-cluster/` (refer to: [inference-config.cfg](./inference-config.cfg))
   - Set `cluster_url` field to your DNS name
   - Ensure paths to certificate and key files are valid

3. **Copy the hosts configuration**:
   ```bash
   cp -f docs/examples/single-node/hosts.yaml core/inventory/hosts.yaml
   ```

4. **Deploy the inference cluster**:
   ```bash
   cd core
   chmod +x inference-stack-deploy.sh
   ./inference-stack-deploy.sh
   ```
   
   - Select Option 1
   - Confirm the Yes/No prompt
   - The Enterprise-Inference cluster will deploy automatically

---

### Step 2: Deploy Enterprise RAG

1. **Clone the Enterprise RAG repository**:
   ```bash
   cd ~
   git clone https://github.com/opea-project/Enterprise-RAG
   ```

2. **Install prerequisites**:
   ```bash
   cd Enterprise-RAG/deployment/
   sudo apt-get install python3-venv
   python3 -m venv erag-venv
   source erag-venv/bin/activate
   pip install --upgrade pip
   pip install -r requirements.txt
   ansible-galaxy collection install -r requirements.yaml --upgrade
   ```

3. **Create configuration directory**:
   ```bash
   cp -r inventory/sample inventory/inference-cluster
   ```

4. **Edit configuration files**:
   - Copy `config.yaml` from the root directory to `inventory/inference-cluster/` (refer to: [config.yaml](./config.yaml))
   - Copy `inventory.ini` from the root directory to `inventory/inference-cluster/` (refer to: [inventory.ini](./inventory.ini))
   - Update the FQDN and domains

5. **Validate hardware and configuration**:
   ```bash
   cd /home/ubuntu/Enterprise-RAG/deployment && source erag-venv/bin/activate && ansible-playbook playbooks/validate.yaml --tags hardware,config -i inventory/inference-cluster/inventory.ini -e @inventory/inference-cluster/config.yaml
   ```
   
   **Sample Expected output**:
   ```
   ok: [localhost] => 
     msg: |-
       Hardware Check Results:
       =====================================================
       Platform: Xeon-only
     
       HARDWARE CHECK PASSED: All requirements met
     
       Total Resources:
       - Total CPU Cores: 96 (Required: 80)
       - Total Memory: 743.63 GB (Required: 250 GB)
       - Total Storage: 476 GB (Required: 200 GB)
     
       Per-Node Details:
       - master1: 96 cores, 743.63 GB RAM
   ```

6. **Deploy the application**:
   ```bash
   cd /home/ubuntu/Enterprise-RAG/deployment && source erag-venv/bin/activate && ansible-playbook playbooks/application.yaml --tags install -i inventory/inference-cluster/inventory.ini -e @inventory/inference-cluster/config.yaml
   ```

7. **Apply Kubernetes patches**:
   ```bash
   kubectl patch statefulset vllm-service-m-deployment -n chatqa --type=json \
     -p='[{"op": "replace", "path": "/spec/template/spec/securityContext/seccompProfile/type", "value": "Unconfined"}]'
   
   kubectl patch configmap vllm-assign-cores -n chatqa --type=json \
     -p='[{"op": "replace", "path": "/data/assign_cores.sh", "value": "#!/bin/bash\n# Copyright (C) 2025 Intel Corporation\n# SPDX-License-Identifier: Apache-2.0\n\necho \"CPU core binding disabled for compatibility\"\nreturn 0\n"}]'
   
   kubectl delete pod vllm-service-m-deployment-0 -n chatqa
   ```

---

## Testing the Deployment

### Verify Deployment Status

Run the connection test script:
```bash
./scripts/test_connection.sh
```

**Expected output**:
```
deployment.apps/client-test created
Waiting for all pods to be running and ready....All pods in the chatqa namespace are running and ready.
Connecting to the server through the pod client-test-87d6c7d7b-45vpb using URL http://router-service.chatqa.svc.cluster.local:8080...
data: '\n'
data: 'A'
data: ':'
data: ' AV'
data: 'X'
data: [DONE]
Test finished successfully
```

---

## Accessing the Services

Once deployment is complete, access the following services through your web browser (replace `erag.com` with your actual domain):

| Service | URL |
|---------|-----|
| **Enterprise RAG UI** | `https://erag.com` |
| **Keycloak** | `https://auth.erag.com` |
| **Grafana** | `https://grafana.erag.com` |
| **MinIO Console** | `https://minio.erag.com` |

---

## Support

For issues or questions, please refer to the official documentation:
- [Enterprise Inference](https://github.com/opea-project/Enterprise-Inference)
- [Enterprise RAG](https://github.com/opea-project/Enterprise-RAG)
