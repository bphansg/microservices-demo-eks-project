#!/bin/bash

# Set variables
USER_NAME="eks-long-lived-user"
PROFILE_NAME="eks-long-lived-user"
CLUSTER_NAME="BP-test"
REGION="us-west-2"  # Change this if your region is different
POLICY_NAME="EKSAccessPolicy"

# Function to run AWS commands with the specified profile
run_aws_command() {
    aws --profile $PROFILE_NAME $@
}

# Test current permissions
echo "Testing current permissions..."
if run_aws_command eks describe-cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
    echo "Current permissions are sufficient."
    exit 0
fi

echo "Current permissions are insufficient. Creating and applying new policy..."

# Create JSON policy file
cat << EOF > eks_access_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:AccessKubernetesApi"
            ],
            "Resource": "*"
        }
    ]
}
EOF

echo "Created eks_access_policy.json"

# Create the IAM policy
POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document file://eks_access_policy.json --query 'Policy.Arn' --output text)

if [ $? -ne 0 ]; then
    echo "Failed to create IAM policy. Exiting."
    exit 1
fi

echo "Created IAM policy: $POLICY_ARN"

# Attach the policy to the user
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

if [ $? -ne 0 ]; then
    echo "Failed to attach policy to user. Exiting."
    exit 1
fi

echo "Successfully attached policy to user $USER_NAME"

# Clean up
rm eks_access_policy.json

echo "Process completed. Please wait a few minutes for the permissions to propagate, then try your operation again."

