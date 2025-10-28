#!/bin/bash
# -----------------------------------------------------------------------------
# install-k8s.sh
#
# Purpose:
#   Installs the OpenTelemetry Demo and New Relic Kubernetes instrumentation
#   into a Kubernetes cluster using Helm charts.
#
# How to run:
#   ./install-k8s.sh
#   (Run from the newrelic/scripts directory)
#
# Dependencies:
#   - kubectl
#   - helm
#   - Access to the target Kubernetes cluster
#   - NEW_RELIC_LICENSE_KEY (will prompt if not set)
# -----------------------------------------------------------------------------
set -euo pipefail

source "$(dirname "$0")/common.sh"

check_tool_installed helm
check_tool_installed kubectl

prompt_for_license_key

install_or_upgrade_chart() {
  local release_name=$1
  local chart=$2
  local version=$3
  local values_file=$4
  local namespace=$5
  if ! helm upgrade "$release_name" "$chart" --version "$version" -f "$values_file" -n "$namespace" --install; then
    echo "Error: Failed to install or upgrade $release_name ($chart) to version $version."
    exit 1
  fi
}

# Create namespace if it doesn't exist
if kubectl get ns "$OTEL_DEMO_NAMESPACE" &> /dev/null; then
  echo "Namespace '$OTEL_DEMO_NAMESPACE' already exists."
else
  kubectl create ns "$OTEL_DEMO_NAMESPACE"
fi

# Create or update New Relic license secret
kubectl create secret generic "$NR_LICENSE_SECRET" --from-literal=license-key="$NEW_RELIC_LICENSE_KEY" -n "$OTEL_DEMO_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Install New Relic K8s OpenTelemetry Collector
ensure_helm_repo "newrelic" "https://helm-charts.newrelic.com"
install_or_upgrade_chart "$NR_K8S_RELEASE_NAME" "newrelic/nr-k8s-otel-collector" "$NR_K8S_CHART_VERSION" "../k8s/helm/nr-k8s-otel-collector.yaml" "$OTEL_DEMO_NAMESPACE"

# Install OpenTelemetry Demo
ensure_helm_repo "open-telemetry" "https://open-telemetry.github.io/opentelemetry-helm-charts"
install_or_upgrade_chart "$OTEL_DEMO_RELEASE_NAME" "open-telemetry/opentelemetry-demo" "$OTEL_DEMO_CHART_VERSION" "../k8s/helm/opentelemetry-demo.yaml" "$OTEL_DEMO_NAMESPACE"

echo "OpenTelemetry Demo installation completed successfully!"
