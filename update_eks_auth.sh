#!/bin/bash

# Set variables
CLUSTER_NAME="BP-test"
REGION="us-west-2"  # Change this to your cluster's region
PROFILE_NAME="eks-long-lived-user"  # Change this if your profile name is different

# Get the ARN of the IAM user or role
ARN=$(aws sts get-caller-identity --profile $PROFILE_NAME --query 'Arn' --output text)

# Determine if it's a user or role ARN
if [[ $ARN == *":user/"* ]]; then
    MAPPING_TYPE="mapUsers"
    IDENTITY_TYPE="userarn"
else
    MAPPING_TYPE="mapRoles"
    IDENTITY_TYPE="rolearn"
fi

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Get the current aws-auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-configmap.yaml

# Check if the ARN already exists in the ConfigMap
if grep -q "$ARN" aws-auth-configmap.yaml; then
    echo "ARN already exists in aws-auth ConfigMap. No changes needed."
else
    # Add the new entry to the ConfigMap
    yq e ".data.$MAPPING_TYPE += \"
- $IDENTITY_TYPE: $ARN
  username: eks-long-lived-user
  groups:
    - system:masters
\"" -i aws-auth-configmap.yaml

    # Apply the updated ConfigMap
    kubectl apply -f aws-auth-configmap.yaml

    echo "Updated aws-auth ConfigMap with new entry."
fi

# Verify the changes
kubectl get configmap aws-auth -n kube-system -o yaml

echo "Script completed. Please test your access to the cluster."

