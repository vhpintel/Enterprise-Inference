#!/bin/bash

# Note: Removed 'set -e' to allow proper exit code handling from quick-sanity.sh

# Parse command line arguments
if [ $# -eq 1 ]; then
    HUGGING_FACE_TOKEN="$1"
    echo "Using command line arguments:"
    echo "  HUGGING_FACE_TOKEN: [PROVIDED]"
else
    echo "Usage: $0 <HUGGING_FACE_TOKEN>"
    echo "Expected 1 argument, got $#"
    exit 1
fi

echo "Adding 127.0.0.1 api.example.com to /etc/hosts if not present..."
if ! grep -q "127.0.0.1 api.example.com" /etc/hosts; then
    if echo "127.0.0.1 api.example.com" | sudo tee -a /etc/hosts > /dev/null; then
        echo "Line added to /etc/hosts."
    else
        echo "Error: Failed to add line to /etc/hosts" >&2
        exit 1
    fi
else
    echo "Entry already exists in /etc/hosts."
fi

# Generate a self-signed SSL certificate for api.example.com if not present
CERT_DIR="$HOME/certs"
KEY_FILE="$CERT_DIR/key.pem"
CERT_FILE="$CERT_DIR/cert.pem"
if [ -f "$KEY_FILE" ] && [ -f "$CERT_FILE" ]; then
    echo "SSL certificate and key already exist at $KEY_FILE and $CERT_FILE. Skipping generation."
else
    echo "Generating self-signed SSL certificate for api.example.com..."
    if mkdir -p "$CERT_DIR" && cd "$CERT_DIR"; then
        if openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=api.example.com"; then
            echo "Certificate and key generated at $KEY_FILE and $CERT_FILE."
        else
            echo "Error: Failed to generate SSL certificate" >&2
            exit 1
        fi
    else
        echo "Error: Failed to create certificate directory" >&2
        exit 1
    fi
fi

# Detect if running in GitHub Actions and set appropriate paths
echo "=== ENVIRONMENT DETECTION ==="
echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-'NOT SET'}"
echo "GITHUB_ACTIONS: ${GITHUB_ACTIONS:-'NOT SET'}"
echo "Current directory: $(pwd)"
echo "Home directory: $HOME"

# Try to find the repository in common locations
POSSIBLE_REPO_DIRS=(
    "$GITHUB_WORKSPACE"
    "$(pwd)"
)

REPO_DIR=""
for dir in "${POSSIBLE_REPO_DIRS[@]}"; do
    if [ -n "$dir" ] && [ -d "$dir" ] && [ -f "$dir/.github/scripts/deployment_validation.sh" ]; then
        REPO_DIR="$dir"
        echo "Found repository at: $REPO_DIR"
        break
    fi
done

if [ -z "$REPO_DIR" ]; then
    echo "Error: Could not find repository in any expected location"
    echo "Searched locations:"
    for dir in "${POSSIBLE_REPO_DIRS[@]}"; do
        if [ -n "$dir" ]; then
            echo "  - $dir (exists: $([ -d "$dir" ] && echo 'yes' || echo 'no'))"
        fi
    done
    echo "Contents of current directory:"
    ls -la .
    exit 1
fi

echo "Using repository directory: $REPO_DIR"
echo "=== END ENVIRONMENT DETECTION ==="

# Create dedicated logs directory
LOGS_DIR="$HOME/deployment_validation_logs"
mkdir -p "$LOGS_DIR"
echo "Created logs directory at: $LOGS_DIR"

# Set log file with timestamp in the dedicated logs directory
LOG_FILE="$LOGS_DIR/deployment_validation_$(date +%Y%m%d_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Logging to: $LOG_FILE"

# Clone repositories
clone_repos() {
    echo "=== REPOSITORY SETUP ==="
    
    # Navigate to the found repository directory
    echo "Navigating to repository directory: $REPO_DIR"
    cd "$REPO_DIR" || {
        echo "Error: Failed to navigate to repository directory: $REPO_DIR" >&2
        exit 1
    }
    
    echo "Current directory after navigation: $(pwd)"
    echo "Repository structure:"
    ls -la .

    # Clean up and clone inference repo
    if [ -d "applications.ai.inference.service.automation" ]; then
        echo "Removing existing inference repo directory..."
        rm -rf "applications.ai.inference.service.automation"
    fi

    echo "Cloning inference repo..."
    git clone https://github.com/intel-innersource/applications.ai.inference.service.automation.git || {
        echo "Error: Failed to clone inference service automation repo" >&2
        exit 1
    }

    # Switch to feature branch
    echo "Switching to feature branch..."
    cd applications.ai.inference.service.automation || {
        echo "Error: Failed to navigate to inference repo directory" >&2
        exit 1
    }

    git fetch origin || {
        echo "Error: Failed to fetch remote branches" >&2
        exit 1
    }

    git checkout inference-integration || {
        echo "Error: Failed to checkout feature branch" >&2
        exit 1
    }

    cd ..
    echo "=== END REPOSITORY SETUP ==="
}

# Ensure test deployment logs directory exists (if needed by quick-sanity script)
TEST_LOGS_DIR="$REPO_DIR/applications.ai.inference.service.automation/test_inference_deployment/logs"
if [ ! -d "$TEST_LOGS_DIR" ]; then
    mkdir -p "$TEST_LOGS_DIR"
    echo "Created test deployment logs directory at: $TEST_LOGS_DIR"
fi

# Setup dependencies and run quick-sanity script
setup_and_run() {
    echo "Installing required dependencies..."

    # Update package list
    if ! sudo apt-get update; then
        echo "Error: Failed to update package list" >&2
        exit 1
    fi

    # Install jq for JSON parsing
    echo "Installing jq..."
    if ! sudo apt-get install -y jq; then
        echo "Error: Failed to install jq" >&2
        exit 1
    fi

    # Install ansible
    echo "Installing ansible..."
    if ! sudo apt-get install -y ansible; then
        echo "Error: Failed to install ansible" >&2
        exit 1
    fi

    echo "Dependencies installed successfully."

    # Navigate to the test deployment directory
    TEST_DIR="$REPO_DIR/applications.ai.inference.service.automation/test_inference_deployment"

    if [ ! -d "$TEST_DIR" ]; then
        echo "Error: Test deployment directory not found at $TEST_DIR" >&2
        exit 1
    fi

    echo "Navigating to test deployment directory: $TEST_DIR"
    cd "$TEST_DIR"

    # Run quick-sanity.sh script
    if [ ! -f "quick-sanity.sh" ]; then
        echo "Error: quick-sanity.sh script not found in $TEST_DIR" >&2
        exit 1
    fi

    echo "Running quick-sanity.sh script..."
    bash quick-sanity.sh "$HUGGING_FACE_TOKEN" cpu 21
    quick_sanity_exit_code=$?

    echo "Quick sanity script completed with exit code: $quick_sanity_exit_code"

    if [ $quick_sanity_exit_code -eq 0 ]; then
        echo "Quick sanity script completed successfully."
    else
        echo "Error: Quick sanity script failed with exit code: $quick_sanity_exit_code" >&2
        exit $quick_sanity_exit_code
    fi
}

# Main execution
main() {
    clone_repos
    setup_and_run
}

main "$@"
