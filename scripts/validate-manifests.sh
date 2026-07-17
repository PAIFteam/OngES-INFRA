#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/namespace.yaml"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/configmap.yaml"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/rabbitmq/"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/core/"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/worker/"
kubectl apply --dry-run=client -f "$ROOT_DIR/k8s/ingress/"
echo "Manifests validados com sucesso."
