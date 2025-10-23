# Copyright (C) 2024-2025 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

install_kubernetes() {
    echo "Starting Kubernetes installation..."
    execute_and_check "Checking if the K8 is installed ..." run_fresh_install_playbook \
        "Kubernetes is installed." \
        "Kubernetes Installation failed. Exiting."
    execute_and_check "Checking if the Kubernetes control plane is ready..." run_k8s_cluster_wait \
        "Kubernetes control plane is ready." \
        "Kubernetes control plane did not become ready in time. Exiting."
    execute_and_check "Setting up kubeconfig for the user..." run_kube_conf_copy_playbook \
        "Kubeconfig is set up." \
        "Failed to set up kubeconfig for the user. Exiting."
}