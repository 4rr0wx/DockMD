# DockMD
<p align="center">
A documentation generator from a docker-compose file
</p>
<p align="center">
<img src="https://github.com/4rr0wx/DockMD/blob/main/DockMD_Logo.png?raw=true" width="250">
</p>


# Installation and requirements
This script uses the package **yq** to parse the yml file.
To Install:
- For Ubuntu and Debian:
```bash
snap install yq
```
- For Mac (brew needs to be installed):
```bash
brew install yq
```

# Usage
```bash
dockmd <./path to docker compose>
```
The script will then start analyzing the docker-compose file provided and will create a `README.md` file in the directory where the script is started from.

# Examples
- TBD

# Support for .env files
The script now supports loading environment variables from a `.env` file located in the same directory as the Docker Compose file. If a `.env` file is present, the script will load the environment variables from it and merge them with those defined in the Docker Compose file.

## Instructions for using .env files
1. Create a `.env` file in the same directory as your Docker Compose file.
2. Define your environment variables in the `.env` file using the format `KEY=VALUE`.
3. Run the `dockmd` script as usual. The script will automatically load and merge the environment variables from the `.env` file with those in the Docker Compose file.
