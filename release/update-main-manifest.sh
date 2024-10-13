#!/bin/bash

MAIN_YAML="kubernetes-manifests.yaml"

# Temporary file for storing the updated content
TEMP_FILE=$(mktemp)

# Read the kubernetes-manifests.yaml file and update image references
while IFS= read -r line
do
    if [[ $line =~ ^[[:space:]]*image:[[:space:]]*(gcr\.io/google-samples/microservices-demo/[^:]+):v[0-9.]+$ ]]; then
        service_name=${BASH_REMATCH[1]##*/}
        echo "        image: tyrion75/westeros:v1\${COMMIT_COUNT}-$service_name" >> "$TEMP_FILE"
    elif [[ $line =~ ^[[:space:]]*image:[[:space:]]*redis:alpine$ ]]; then
        echo "$line" >> "$TEMP_FILE"
    else
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$MAIN_YAML"

# Replace the original file with the updated content
mv "$TEMP_FILE" "$MAIN_YAML"

echo "Updated kubernetes-manifests.yaml with new image references."
