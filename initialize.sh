#!/bin/bash
export CONFIG_PATH=$PWD/kubernetes/config
export KUBECONFIG=${CONFIG_PATH}/config

kubectl apply -f ${CONFIG_PATH}/config_map_aws_auth.yaml
# Helm
kubectl apply -f ${CONFIG_PATH}/rbac-tiller.yaml
helm init --service-account tiller

sleep 5

helm repo add istio.io https://storage.googleapis.com/istio-prerelease/daily-build/master-latest-daily/charts
helm install istio --name istio

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
