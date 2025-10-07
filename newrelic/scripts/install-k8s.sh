#!/bin/bash

OTEL_DEMO_CHART_VERSION="0.38.1"

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

# Prefer NEW_RELIC_LICENSE_KEY environment variable; otherwise prompt the user
if [ -n "$NEW_RELIC_LICENSE_KEY" ]; then
    license_key="$NEW_RELIC_LICENSE_KEY"
    echo "Using New Relic license key from NEW_RELIC_LICENSE_KEY environment variable."
else
    echo -n "Please enter your New Relic License Key: "
    read -r license_key

    # Check if input is empty
    if [ -z "$license_key" ]; then
        echo "Error: Empty key. Please enter your New Relic License Key."
        exit 1
    fi
fi

# Check if the opentelemetry-demo namespace already exists
if kubectl get ns opentelemetry-demo &> /dev/null; then
    echo "Namespace 'opentelemetry-demo' already exists."
else
    kubectl create ns opentelemetry-demo
fi

# Create the secret; if it already exists, replace it so the script is idempotent
if kubectl create secret generic newrelic-license-key --from-literal=license-key="$license_key" -n opentelemetry-demo 2>/dev/null; then
    echo "Created secret 'newrelic-license-key' in namespace 'opentelemetry-demo'."
else
    echo "Secret 'newrelic-license-key' already exists; replacing it."
    kubectl delete secret newrelic-license-key -n opentelemetry-demo
    kubectl create secret generic newrelic-license-key --from-literal=license-key="$license_key" -n opentelemetry-demo
fi

# Check if the open-telemetry repo is already added
if helm repo list | grep -q 'open-telemetry'; then
    echo "Helm repository 'open-telemetry' is already added."
else
    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
fi

# Update Helm repository
if ! helm repo update open-telemetry; then
    echo "Error: Failed to update open-telemetry Helm repository."
    exit 1
fi

# Install/upgrade OpenTelemetry demo
if ! helm upgrade --install otel-demo open-telemetry/opentelemetry-demo --version ${OTEL_DEMO_CHART_VERSION} -n opentelemetry-demo -f ../k8s/helm/values.yaml; then
    echo "Error: Failed to install or upgrade OpenTelemetry Demo to ${OTEL_DEMO_CHART_VERSION}."
    exit 1
fi

echo "OpenTelemetry Demo installation completed successfully!"
