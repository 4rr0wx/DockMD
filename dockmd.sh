#!/bin/bash
# Author: 4rr0wx (https://github.com/4rr0wx)
# A documentation generator from a docker-compose file, including a Table of Contents

# Version: 0.3

# Path to the Docker Compose file
DOCKER_COMPOSE_FILE="$1"
# Determine the directory of the Docker Compose file
COMPOSE_DIR=$(dirname "$DOCKER_COMPOSE_FILE")
# Path to the README file to generate, now relative to the Docker Compose file's location
README_FILE="$COMPOSE_DIR/README.md"

# Start the README file with a title and a description
{
echo "# Project Services"
echo "This README provides an overview of the services defined in the Docker Compose file of this project."
echo ""
echo "To start this stack:"
echo "(Your working dir needs to be where the docker-compose file is)"
echo "\`\`\`bash"
echo "docker compose up -d"
echo "\`\`\`"
echo ""
} > "$README_FILE"

# Check if Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Docker Compose file not found: $DOCKER_COMPOSE_FILE" >&2
    exit 1
fi

# Placeholder for services to generate TOC
declare -a services

# Extract service names for TOC
mapfile -t services < <(yq e '.services | keys | .[]' "$DOCKER_COMPOSE_FILE")

# Generate TOC
{
echo "## Table of Contents"
echo "- [Project Services](#project-services)"
echo "  - [Services](#services)"
for service in "${services[@]}"; do
    echo "    - [$service](#$service)"
done
echo ""
} >> "$README_FILE"

# Extract and write service information
echo "## Services" >> "$README_FILE"
for service_name in "${services[@]}"; do
    {
    echo "### $service_name"
    # Extract image name
    image_name=$(yq e ".services.$service_name.image" "$DOCKER_COMPOSE_FILE")
    echo "- **Image:** $image_name"
    # Extract ports
    ports=$(yq e ".services.$service_name.ports | .[]" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$ports" != "null" ] && [ ! -z "$ports" ]; then
        echo "- **Ports:**"
        while IFS= read -r port; do
            echo "  - $port"
        done <<< "$ports"
    fi
    # Extract volumes
    volumes=$(yq e ".services.$service_name.volumes | .[]" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$volumes" != "null" ] && [ ! -z "$volumes" ]; then
        echo "- **Volumes:**"
        while IFS= read -r volume; do
            echo "  - $volume"
        done <<< "$volumes"
    fi
    # Extract environment variables
    env_vars=$(yq e ".services.$service_name.environment | to_entries | .[] | .key + \": \" + .value" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
    if [ "$env_vars" != "null" ] && [ ! -z "$env_vars" ]; then
        echo "- **Environment Variables:**"
        while IFS= read -r env_var; do
            echo "  - $env_var"
        done <<< "$env_vars"
    fi
    echo ""
    } >> "$README_FILE"
done

echo "README.md has been generated in $COMPOSE_DIR."
