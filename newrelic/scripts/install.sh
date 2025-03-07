#!/bin/bash

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed or not in PATH. Please install helm and try again."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH. Please install kubectl and try again."
    exit 1
fi

# Prompt the user for input
echo -n "Please enter your New Relic License Key: "
read user_input

# Check if input is empty
if [ -z "$user_input" ]; then
    echo "Error: Empty key. Please enter your New Relic License Key."
    exit 1
fi

# Echo the input back to the user
# echo "You entered: $user_input"
kubectl create ns opentelemetry-demo && kubectl create secret generic newrelic-license-key --from-literal=license-key=$user_input -n opentelemetry-demo
helm upgrade --install otel-demo open-telemetry/opentelemetry-demo -n opentelemetry-demo -f ../helm/values.yaml