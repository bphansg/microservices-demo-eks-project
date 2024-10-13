#!/bin/bash

DOCKERHUB_USERNAME="tyrion75"

# Check if DOCKERHUB_PASSWORD is set
if [ -z "$DOCKERHUB_PASSWORD" ]; then
    echo "Error: DOCKERHUB_PASSWORD environment variable must be set."
    exit 1
fi

# Login to Docker Hub
echo "Logging in to Docker Hub..."
echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

if [ $? -ne 0 ]; then
    echo "Failed to log in to Docker Hub. Please check your credentials."
    exit 1
fi

# Function to create a Docker Hub repository
create_repo() {
    local service_name=$1
    echo "Attempting to create repository for $service_name"
    
    # Attempt to create a repository by pushing a dummy image
    docker pull hello-world
    docker tag hello-world "$DOCKERHUB_USERNAME/$service_name:init"
    docker push "$DOCKERHUB_USERNAME/$service_name:init"
    
    if [ $? -eq 0 ]; then
        echo "Repository $service_name created successfully."
        # Clean up the dummy image
        docker rmi "$DOCKERHUB_USERNAME/$service_name:init"
    else
        echo "Failed to create repository $service_name."
    fi
}

# Update Kubernetes manifests
update_manifest() {
    local service_name=$1
    echo "Updating manifests for $service_name"
    sed -i "s|image:.*${service_name}.*|image: ${DOCKERHUB_USERNAME}/${service_name}:latest|g" kubernetes-manifests/*.yaml release/kubernetes-manifests.yaml
}

echo "Searching for services in src/ directory..."
for dir in src/*/; do
    if [ -f "${dir}Dockerfile" ]; then
        service_name=$(basename "$dir")
        echo "Found service: $service_name"
        create_repo "$service_name"
        update_manifest "$service_name"
    fi
done

# Logout from Docker Hub
docker logout

echo "Repository creation and manifest update process completed."

