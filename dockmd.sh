#!/bin/bash
# Author: 4rr0wx (https://github.com/4rr0wx)
# A documentation generator from a docker-compose file

# Version: 0.2

# Path to the Docker Compose file
DOCKER_COMPOSE_FILE="$1"
# Determine the directory of the Docker Compose file
COMPOSE_DIR=$(dirname "$DOCKER_COMPOSE_FILE")
# Path to the README file to generate, now relative to the Docker Compose file's location
README_FILE="$COMPOSE_DIR/README.md"

# Start the README file with a title and a description
echo "# Project Services" > "$README_FILE"
echo "This README provides an overview of the services defined in the Docker Compose file of this project." >> "$README_FILE"
echo "" >> "$README_FILE"
echo "To start this stack:" >> "$README_FILE"
echo "(Your working dir needs to be where the docker-compose file is)" >> "$README_FILE"
echo "\`\`\`bash" >> "$README_FILE"
echo "docker compose up -d" >> "$README_FILE"
echo "\`\`\`" >> "$README_FILE"
echo "" >> "$README_FILE"

# Check if Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Docker Compose file not found: $DOCKER_COMPOSE_FILE"
    exit 1
fi

# Extract and write service information
echo "## Services" >> "$README_FILE"
yq e '.services | keys | .[]' "$DOCKER_COMPOSE_FILE" | while read -r service_name; do
    echo "### $service_name" >> "$README_FILE"
    # Extract image name
    image_name=$(yq e ".services.$service_name.image" "$DOCKER_COMPOSE_FILE")
    echo "- **Image:** $image_name" >> "$README_FILE"
    # Extract ports
    ports=$(yq e ".services.$service_name.ports | .[]" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$ports" != "null" ] && [ ! -z "$ports" ]; then
        echo "- **Ports:**" >> "$README_FILE"
        echo "$ports" | while read -r port; do
            echo "  - $port" >> "$README_FILE"
        done
    fi
    # Extract volumes
    volumes=$(yq e ".services.$service_name.volumes | .[]" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$volumes" != "null" ] && [ ! -z "$volumes" ]; then
        echo "- **Volumes:**" >> "$README_FILE"
        echo "$volumes" | while read -r volume; do
            echo "  - $volume" >> "$README_FILE"
        done
    fi
    # Extract environment variables
    env_vars=$(yq e ".services.$service_name.environment | to_entries | .[] | .key + \": \" + .value" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$env_vars" != "null" ] && [ ! -z "$env_vars" ]; then
        echo "- **Environment Variables:**" >> "$README_FILE"
        echo "$env_vars" | while read -r env_var; do
            echo "  - $env_var" >> "$README_FILE"
        done
    fi
    echo "" >> "$README_FILE"
done

echo "README.md has been generated in $COMPOSE_DIR."
