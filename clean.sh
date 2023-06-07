#!/bin/bash

# Move files from "./tmp" back to the current directory
mv ./tmp/*-* ./

# namespace for all the tools
namespaces=("istio-system" "logging" "monitoring" "cert-manager" "kube-system" "argocd" "vault" "ingress-nginx" "istio-ingress")

# Iterate over each namespace and perform cleanup
for namespace in "${namespaces[@]}"; do
  helm list -n "$namespace" | awk 'NR>1 {print $1}' | xargs helm delete -n "$namespace"
done

# Run "terraform destroy" command
terraform destroy