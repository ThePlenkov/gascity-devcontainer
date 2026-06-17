FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install common utils
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*

# Copy and install gascity feature
COPY .devcontainer/features/gascity /tmp/gascity-feature
RUN chmod +x /tmp/gascity-feature/devcontainer-features-install.sh && \
    /tmp/gascity-feature/devcontainer-features-install.sh

# Copy and install devin feature
COPY .devcontainer/features/devin /tmp/devin-feature
RUN chmod +x /tmp/devin-feature/devcontainer-features-install.sh && \
    /tmp/devin-feature/devcontainer-features-install.sh

# Copy and install claude feature
COPY .devcontainer/features/claude /tmp/claude-feature
RUN chmod +x /tmp/claude-feature/devcontainer-features-install.sh && \
    /tmp/claude-feature/devcontainer-features-install.sh

# Clean up
RUN rm -rf /tmp/gascity-feature /tmp/devin-feature /tmp/claude-feature

WORKDIR /workspace
