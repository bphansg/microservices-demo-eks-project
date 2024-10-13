#!/bin/bash

DOCKERHUB_USERNAME="tyrion75"

# Function to update image references in a file
update_image_references() {
    local file=$1
    echo "Updating image references in $file"
    
    # Extract the service name from the file name
    service_name=$(basename "$file" .yaml)
    
    # Use sed to replace image references, compatible with macOS
    sed -i '' "s|image: ${DOCKERHUB_USERNAME}/westeros:.*|image: ${DOCKERHUB_USERNAME}/${service_name}:latest|g" "$file"
}

# Update kubernetes-manifests directory
echo "Updating manifests in kubernetes-manifests directory..."
for file in kubernetes-manifests/*.yaml; do
    update_image_references "$file"
done

# Update release/kubernetes-manifests.yaml
echo "Updating release/kubernetes-manifests.yaml..."
sed -i '' "s|image: ${DOCKERHUB_USERNAME}/westeros:.*-\(.*\)|image: ${DOCKERHUB_USERNAME}/\1:latest|g" "release/kubernetes-manifests.yaml"

echo "Image reference update completed."

