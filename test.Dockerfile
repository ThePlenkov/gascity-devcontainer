FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install common utils
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*

# Copy and install gascity feature
COPY src/gascity /tmp/gascity-feature
RUN chmod +x /tmp/gascity-feature/install.sh && \
    /tmp/gascity-feature/install.sh

# Copy and install devin feature
COPY src/devin /tmp/devin-feature
RUN chmod +x /tmp/devin-feature/install.sh && \
    /tmp/devin-feature/install.sh

# Copy and install claude feature
COPY src/claude /tmp/claude-feature
RUN chmod +x /tmp/claude-feature/install.sh && \
    /tmp/claude-feature/install.sh

# Clean up
RUN rm -rf /tmp/gascity-feature /tmp/devin-feature /tmp/claude-feature

WORKDIR /workspace
