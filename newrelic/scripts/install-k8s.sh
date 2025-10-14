#!/bin/bash

OTEL_DEMO_CHART_VERSION=0.38.1
NR_K8S_OTEL_CHART_VERSION=0.8.50

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

# Check if the opentelemetry-demo namespace already exists
if kubectl get ns opentelemetry-demo &> /dev/null; then
    echo "Namespace 'opentelemetry-demo' already exists."
else
    kubectl create ns opentelemetry-demo && kubectl create secret generic newrelic-license-key --from-literal=license-key=$user_input -n opentelemetry-demo
fi

# Check if the newrelic namespace already exists
if kubectl get ns newrelic &> /dev/null; then
    echo "Namespace 'newrelic' already exists."
else
    kubectl create ns newrelic && kubectl create secret generic newrelic-license-key --from-literal=license-key=$user_input -n newrelic
fi

# Check if the open-telemetry repo is already added
if helm repo list | grep -q 'open-telemetry'; then
    echo "Helm repository 'open-telemetry' is already added."
else
    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
    helm repo update open-telemetry
fi

# Check if the newrelic repo is already added
if helm repo list | grep -q 'newrelic'; then
    echo "Helm repository 'newrelic' is already added."
else
    helm repo add newrelic https://helm-charts.newrelic.com
    helm repo update newrelic
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

# Install/upgrade New Relic OTel Collector demo
if ! helm upgrade --install nr-k8s-otel-collector newrelic/nr-k8s-otel-collector --version ${NR_K8S_OTEL_CHART_VERSION} -n newrelic -f ../k8s/helm/nr-k8s-otel-collector-values.yaml; then
    echo "Error: Failed to install or upgrade the New Relic OTel Collector to ${NR_K8S_OTEL_CHART_VERSION}."
    exit 1
fi

echo "New Relic OTel Collector installation completed successfully!"
