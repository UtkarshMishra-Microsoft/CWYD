# .devcontainer/Dockerfile

FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

# Install git and system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        git \
        libgtk2.0-0 \
        libgtk-3-0 \
        libgbm-dev \
        libnotify-dev \
        libnss3 \
        libxss1 \
        libasound2 \
        libxtst6 \
        xauth \
        xvfb

# Install Azure CLI using the official script (works for bookworm)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install required Python dependencies
RUN pip install --upgrade pip \
    && pip install poetry \
    && pip install poetry-plugin-export \
    && pip install azure-mgmt-rdbms
