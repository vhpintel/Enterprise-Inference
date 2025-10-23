# Copyright (C) 2024-2025 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

list_inference_llm_models_playbook() {
    echo "Listing installed Inference LLM Models playbook..."
    # Read existing parameters
    # Execute the Ansible playbook with all parameters
    echo $model_name_list
    echo "Listing the models..."
    list_model_true="true"       
    ansible-playbook -i "${INVENTORY_PATH}" playbooks/deploy-inference-models.yml \
        --extra-vars "secret_name=${cluster_url} cert_file=${cert_file} key_file=${key_file} keycloak_admin_user=${keycloak_admin_user} keycloak_admin_password=${keycloak_admin_password} keycloak_client_id=${keycloak_client_id} hugging_face_token=${hugging_face_token} uninstall_true=${uninstall_true} list_model_true='${list_model_true//\ /,}'" --vault-password-file "$vault_pass_file"
}


list_models() {
    list_model_menu="skip"
    read_config_file        
    prompt_for_input      
    if [ -z "$cluster_url" ] || [ -z "$cert_file" ] || [ -z "$key_file" ] || [ -z "$keycloak_client_id" ] || [ -z "$keycloak_admin_user" ] || [ -z "$keycloak_admin_password" ]; then
        echo "Some required arguments are missing. Prompting for input..."
        prompt_for_input
    fi                
    invoke_prereq_workflows       
    execute_and_check "Listing Inference LLM Models..." list_inference_llm_models_playbook "$@" \
        "Inference LLM Model listed successfully." \
        "Failed to list Inference LLM Model Exiting!."    
}