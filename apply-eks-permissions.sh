#!/bin/bash

# Set variables
POLICY_NAME="EKSLongLivedUserPolicy"
USER_NAME="eks-long-lived-user"

# Create the policy document
cat << EOF > policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:DescribeNodegroup",
        "eks:DescribeFargateProfile",
        "ec2:DescribeSubnets",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the IAM policy
POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document file://policy.json --query 'Policy.Arn' --output text)

if [ $? -ne 0 ]; then
    echo "Failed to create policy. Exiting."
    exit 1
fi

echo "Created policy: $POLICY_ARN"

# Attach the policy to the user
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

if [ $? -ne 0 ]; then
    echo "Failed to attach policy to user. Exiting."
    exit 1
fi

echo "Successfully attached policy to user

