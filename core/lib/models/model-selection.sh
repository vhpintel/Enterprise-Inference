# Copyright (C) 2024-2025 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

model_selection(){
    
    if [ "$list_model_menu" != "skip" ]; then
        if [ -z "$hugging_face_token" ] && [ "$deploy_llm_models" = "yes" ]; then
            read -p "Enter the token for Huggingface: " hugging_face_token
        else
            echo "Using provided Huggingface token"            
        fi
        if [ -z "$deploy_llm_models" ]; then
            read -p "Do you want to proceed with deploying Large Language Model (LLM)? (yes/no): " deploy_llm_models
            if [ "$deploy_llm_models" == "yes" ]; then
                model_name_list=$(get_model_names)    
                echo "Proceeding to deploy models: $model_name_list"
            fi
        else
            model_name_list=$(get_model_names)                       
            echo "Proceeding with the setup of Large Language Model (LLM): $deploy_llm_models"
        fi
        if [ "$deploy_llm_models" = "yes" ]; then
            if [ "$hugging_face_model_deployment" != "true" ]; then                        
                if [ -z "$models" ]; then
                    if [ "$hugging_face_model_remove_deployment" != "true" ]; then
                        if [ "$cpu_or_gpu" = "g" ]; then
                            # Prompt for GPU models
                            echo "Available GPU models:"
                            echo "1. llama-8b"
                            echo "2. llama-70b"
                            echo "3. codellama-34b"
                            echo "4. mixtral-8x-7b"
                            echo "5. mistral-7b"
                            echo "6. tei"
                            echo "7. tei-rerank"
                            echo "8. falcon3-7b"
                            echo "9. deepseek-r1-distill-qwen-32b"
                            echo "10. deepseek-r1-distill-llama8b"
                            echo "11. llama3-405b"
                            echo "12. llama-3-3-70b"
                            read -p "Enter the numbers of the GPU models you want to deploy/remove (comma-separated, e.g., 1,3,5): " models
                        else
                            # Prompt for CPU models
                            echo "Available CPU models:"
                            echo "21. cpu-llama-8b"
                            echo "22. cpu-deepseek-r1-distill-qwen-32b"
                            echo "23. cpu-deepseek-r1-distill-llama8b"
                            read -p "Enter the number of the CPU model you want to deploy/remove: " cpu_model
                            models="$cpu_model"
                        fi
                    fi
                else
                    if [ "$hugging_face_model_deployment" != "true" ]; then
                        echo "Using provided models: $models"
                    fi
                fi
                
                model_names=$(get_model_names)                        
                if [ "$hugging_face_model_remove_deployment" != "true" ]; then
                    if [ -n "$model_names" ]; then
                        if [ "$hugging_face_model_deployment" != "true" ]; then                    
                            if [ "$cpu_or_gpu" = "g" ]; then
                                echo "Deploying/removing GPU models: $model_names"                    
                            else
                                echo "Deploying/removing CPU models: $model_names"                    
                            fi
                        fi
                    fi
                fi            
            fi
        else
            echo "Skipping model deployment/removal."
        fi

        
    fi
    
}


get_model_names() {
    local model_names=()
    IFS=','    
    read -ra model_array <<< "$models"
    for model in "${model_array[@]}"; do
        case "$model" in
            1)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("llama-8b")
                ;;
            2)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("llama-70b")
                ;;
            3)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("codellama-34b")
                ;;
            4)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("mixtral-8x-7b")
                ;;
            5)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("mistral-7b")
                ;;
            6)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("tei")
                ;;
            7)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("rerank")
                ;;
            8)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("falcon3-7b")
                ;;
            9)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("deepseek-r1-distill-qwen-32b")
                ;;
            10)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("deepseek-r1-distill-llama8b")
                ;;
            11)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("llama3-405b")
                ;;
            12)
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("llama-3-3-70b")
                ;;
            21)
                if [ "$cpu_or_gpu" = "g" ]; then
                    echo "Error: CPU model identifier provided for GPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("cpu-llama-8b")
                ;;
            22)
                if [ "$cpu_or_gpu" = "g" ]; then
                    echo "Error: CPU model identifier provided for GPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("cpu-deepseek-r1-distill-qwen-32b")
                ;;
            23)
                if [ "$cpu_or_gpu" = "g" ]; then
                    echo "Error: CPU model identifier provided for GPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("cpu-deepseek-r1-distill-llama8b")
                ;;
            "llama-8b"|"llama-70b"|"codellama-34b"|"mixtral-8x-7b"|"mistral-7b"|"tei"|"tei-rerank"|"falcon3-7b"|"deepseek-r1-distill-qwen-32b"|"deepseek-r1-distill-llama8b"|"llama3-405b"|"llama-3-3-70b")
                if [ "$cpu_or_gpu" = "c" ]; then
                    echo "Error: GPU model identifier provided for CPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("$model")
                ;;
            "cpu-llama-8b"|"cpu-deepseek-r1-distill-qwen-32b"|"cpu-deepseek-r1-distill-llama8b")
                if [ "$cpu_or_gpu" = "g" ]; then
                    echo "Error: CPU model identifier provided for GPU deployment/removal." >&2
                    exit 1
                fi
                model_names+=("$model")
                ;;
            *)
                echo "Error: Invalid model identifier: $model" >&2
                exit 1
                ;;
        esac
    done
    echo "${model_names[@]}"
}
