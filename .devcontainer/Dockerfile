ARG VARIANT="3.11-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

# Install act - For testing Github Actions
RUN curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash