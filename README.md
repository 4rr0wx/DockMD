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
