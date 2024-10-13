#!/bin/bash

CLUSTER_NAME="BP-test"
REGION="us-west-2"
PROFILE_NAME="eks-long-lived-user"

# Get user ARN
USER_ARN=$(aws sts get-caller-identity --profile $PROFILE_NAME --query 'Arn' --output text)

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Get current aws-auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-configmap.yaml

# Add user to aws-auth ConfigMap
if ! grep -q "$USER_ARN" aws-auth-configmap.yaml; then
    sed -i '/mapUsers: |/a\  - userarn: '"$USER_ARN"'\n    username: eks-long-lived-user\n    groups:\n      - system:masters' aws-auth-configmap.yaml
    kubectl apply -f aws-auth-configmap.yaml
    echo "User added to aws-auth ConfigMap"
else
    echo "User already exists in aws-auth ConfigMap"
fi

# Verify changes
kubectl get configmap aws-auth -n kube-system -o yaml

echo "Authorization update complete. Please test your access to the cluster."

