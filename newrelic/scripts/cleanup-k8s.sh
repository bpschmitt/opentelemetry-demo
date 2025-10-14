#!/bin/bash

otel_release_name=otel-demo
otel_namespace=opentelemetry-demo
nr_release_name=nr-k8s-otel-collector
nr_namespace=newrelic

# Check if the OTel Demo Helm release exists
if helm status "$otel_release_name" -n $otel_namespace &> /dev/null; then
    echo "Helm release '$otel_release_name' found. Uninstalling..."
    helm uninstall "$otel_release_name" -n $otel_namespace
    if [ $? -eq 0 ]; then
        echo "Successfully uninstalled '$release_name'"
    else
        echo "Failed to uninstall '$release_name'"
        exit 1
    fi
else
    echo "Helm release '$otel_release_name' not found."
fi

# Check if OTel Demonamespace exists
if kubectl get namespace "$otel_namespace" &> /dev/null; then
    echo "Namespace '$otel_namespace' found. Deleting..."
    kubectl delete namespace "$otel_namespace"
    if [ $? -eq 0 ]; then
        echo "Successfully deleted namespace '$otel_namespace'"
    else
        echo "Failed to delete namespace '$otel_namespace'"
        exit 1
    fi
else
    echo "Namespace '$otel_namespace' not found."
fi

# Check if the New Relic Opentelemetry for Kubernetes Helm release exists
if helm status "$nr_release_name" -n $nr_namespace &> /dev/null; then
    echo "Helm release '$nr_release_name' found. Uninstalling..."
    helm uninstall "$nr_release_name" -n $nr_namespace
    if [ $? -eq 0 ]; then
        echo "Successfully uninstalled '$nr_release_name'"
    else
        echo "Failed to uninstall '$nr_release_name'"
        exit 1
    fi
else
    echo "Helm release '$nr_release_name' not found."
fi

# Check if New Relic namespace exists
if kubectl get namespace "$nr_namespace" &> /dev/null; then
    echo "Namespace '$nr_namespace' found. Deleting..."
    kubectl delete namespace "$nr_namespace"
    if [ $? -eq 0 ]; then
        echo "Successfully deleted namespace '$nr_namespace'"
    else
        echo "Failed to delete namespace '$nr_namespace'"
        exit 1
    fi
else
    echo "Namespace '$nr_namespace' not found."
fi

exit 0