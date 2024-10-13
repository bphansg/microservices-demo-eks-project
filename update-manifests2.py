import yaml

def add_image_pull_policy(data):
    if isinstance(data, dict):
        if data.get('kind') == 'Deployment':
            containers = data.get('spec', {}).get('template', {}).get('spec', {}).get('containers', [])
            for container in containers:
                if 'image' in container and 'imagePullPolicy' not in container:
                    container['imagePullPolicy'] = 'Always'
        for value in data.values():
            add_image_pull_policy(value)
    elif isinstance(data, list):
        for item in data:
            add_image_pull_policy(item)

# Read the YAML file
with open('release/kubernetes-manifests.yaml', 'r') as file:
    manifests = list(yaml.safe_load_all(file))

# Modify the manifests
for manifest in manifests:
    add_image_pull_policy(manifest)

# Write the modified YAML back to the file
with open('release/kubernetes-manifests.yaml', 'w') as file:
    yaml.dump_all(manifests, file, default_flow_style=False)

print("Added imagePullPolicy: Always to all Deployments in kubernetes-manifests.yaml")

