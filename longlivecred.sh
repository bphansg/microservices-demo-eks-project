#!/bin/bash

# Set variables
USER_NAME="eks-long-lived-user"
PROFILE_NAME="eks-long-lived-user"

# Ensure the AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and try again."
    exit 1
fi

# List existing access keys
echo "Listing existing access keys for $USER_NAME..."
EXISTING_KEYS=$(aws iam list-access-keys --user-name $USER_NAME --query 'AccessKeyMetadata[*].AccessKeyId' --output text)

# Count the number of existing keys
KEY_COUNT=$(echo $EXISTING_KEYS | wc -w)

if [ $KEY_COUNT -ge 2 ]; then
    echo "User already has the maximum number of access keys (2)."
    echo "Existing key IDs: $EXISTING_KEYS"
    read -p "Enter the ID of the key you want to delete: " KEY_TO_DELETE
    
    aws iam delete-access-key --user-name $USER_NAME --access-key-id $KEY_TO_DELETE
    if [ $? -ne 0 ]; then
        echo "Failed to delete the access key. Please check the key ID and try again."
        exit 1
    fi
    echo "Access key deleted successfully."
fi

# Create a new access key for the user
echo "Creating new access key for $USER_NAME..."
KEY_OUTPUT=$(aws iam create-access-key --user-name $USER_NAME --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)

if [ $? -ne 0 ]; then
    echo "Failed to create access key. Make sure you have the necessary permissions and the user exists."
    exit 1
fi

# Extract the Access Key ID and Secret Access Key
ACCESS_KEY_ID=$(echo $KEY_OUTPUT | awk '{print $1}')
SECRET_ACCESS_KEY=$(echo $KEY_OUTPUT | awk '{print $2}')

# Configure the AWS CLI profile
echo "Configuring AWS CLI profile '$PROFILE_NAME'..."
aws configure set aws_access_key_id $ACCESS_KEY_ID --profile $PROFILE_NAME
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY --profile $PROFILE_NAME
aws configure set region us-west-2 --profile $PROFILE_NAME  # Change this to your preferred region

echo "Profile '$PROFILE_NAME' has been configured with the new credentials."
echo "You can now use this profile with: aws --profile $PROFILE_NAME [command]"

