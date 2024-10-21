#!/bin/bash
# Author: 4rr0wx (https://github.com/4rr0wx)
# A documentation generator from a docker-compose file, including a Table of Contents

# Version: 0.9

# Path to the Docker Compose file
DOCKER_COMPOSE_FILE="$1"
# Determine the directory of the Docker Compose file
COMPOSE_DIR=$(dirname "$DOCKER_COMPOSE_FILE")
# Path to the README file to generate, now relative to the Docker Compose file's location
README_FILE="$COMPOSE_DIR/README.md"
# Temporary README file for comparison
TEMP_README_FILE="$COMPOSE_DIR/README_TEMP.md"
# File to keep track of the README version
VERSION_FILE="$COMPOSE_DIR/README_VERSION.txt"

# Check if Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Docker Compose file not found: $DOCKER_COMPOSE_FILE" >&2
    exit 1
fi

# Initialize or read the version number
if [ ! -f "$VERSION_FILE" ]; then
    echo "1" > "$VERSION_FILE"
    VERSION=1
else
    VERSION=$(<"$VERSION_FILE")
fi

# Function to prompt user for section selection
prompt_user_selection() {
    echo "Select sections to include in the README (y/n):"
    read -p "Include services? (y/n): " include_services
    read -p "Include volumes? (y/n): " include_volumes
    read -p "Include networks? (y/n): " include_networks
    read -p "Include environment variables? (y/n): " include_env_vars
}

# Call the function to prompt user for section selection
prompt_user_selection

# Start the temporary README file with a title, description, and instructions
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
} > "$TEMP_README_FILE"

# Placeholder for services to generate TOC
declare -a services

# Extract service names for TOC
mapfile -t services < <(yq e '.services | keys | .[]' "$DOCKER_COMPOSE_FILE")

# Generate TOC in the temporary file
{
echo "## Table of Contents"
echo "- [Project Services](#project-services)"
for service in "${services[@]}"; do
    echo "    - [$service](#$service)"
done
echo ""
} >> "$TEMP_README_FILE"

# Extract and write service information to the temporary file
echo "## Services" >> "$TEMP_README_FILE"
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
        echo "$ports" | while IFS= read -r port; do
            echo "  - $port"
        done
    fi
    # Extract volumes
    if [ "$include_volumes" == "y" ]; then
        volumes=$(yq e ".services.$service_name.volumes | .[]" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
        if [ "$volumes" != "null" ] && [ ! -z "$volumes" ]; then
            echo "- **Volumes:**"
            echo "$volumes" | while IFS= read -r volume; do
                echo "  - $volume"
            done
        fi
    fi
    # Extract environment variables
    if [ "$include_env_vars" == "y" ]; then
        env_vars=$(yq e ".services.$service_name.environment | to_entries | .[] | .key + \": \" + .value" "$DOCKER_COMPOSE_FILE" 2>/dev/null)
        if [ "$env_vars" != "null" ] && [ ! -z "$env_vars" ]; then
            echo "- **Environment Variables:**"
            while IFS= read -r env_var; do           
                echo "  - $env_var"
            done <<< "$env_vars"
        fi
    fi
    echo ""
    } >> "$TEMP_README_FILE"
done

# Add the Last Changed and Version to the temporary README
        {
        echo "## Version"
        echo "For the latest version of this README, view README_VERSION.txt"
        } >> "$TEMP_README_FILE"

# Check if README already exists and if it's different from the temporary one
if [ -f "$README_FILE" ]; then
    if ! cmp --silent "$README_FILE" "$TEMP_README_FILE" ; then
        echo "README.md already exists. What would you like to do?"
        echo "1. Overwrite"
        echo "2. Append"
        echo "3. Do nothing"
        read -p "Enter your choice (1/2/3): " choice

        case $choice in
            1)
                mv "$TEMP_README_FILE" "$README_FILE"
                echo "README.md has been overwritten in $COMPOSE_DIR."
                # Increment the version number and update the Last Changed timestamp
                ((VERSION++))
                echo "$VERSION" > "$VERSION_FILE"
                echo "README.md version updated to $VERSION."
                ;;
            2)
                cat "$TEMP_README_FILE" >> "$README_FILE"
                rm "$TEMP_README_FILE"
                echo "New content has been appended to README.md in $COMPOSE_DIR."
                ;;
            3)
                rm "$TEMP_README_FILE"
                echo "No changes made to README.md."
                ;;
            *)
                rm "$TEMP_README_FILE"
                echo "Invalid choice. No changes made to README.md."
                ;;
        esac
    else
        echo "README.md already exists and is up to date in $COMPOSE_DIR."
        rm "$TEMP_README_FILE"
    fi
else
    mv "$TEMP_README_FILE" "$README_FILE"
    echo "README.md has been generated in $COMPOSE_DIR."
    # No need to increment version for the first creation
fi
