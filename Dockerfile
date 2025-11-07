FROM node:20-slim

# Install basic system packages
RUN apt-get update && apt-get install -y \
    mc \
    python3 \
    make \
    g++ \
    curl \
    git \
    wget \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/* && \
    gh --version
RUN npm install -g opencode-ai@0.15.31

# Create opencode configuration directories
RUN mkdir -p /root/.config/opencode/agent \
    /root/.config/opencode/plugin \
    /root/.cache/opencode \
    /root/.local/share/opencode \
    /root/.local/state/opencode

# Set working directory
WORKDIR /root

# Copy opencode configuration
COPY opencode.json /root/opencode.json
COPY config/agent /root/.config/opencode/agent
COPY config/plugin /root/.config/opencode/plugin
COPY config/package.json /root/.config/opencode/package.json
COPY config/state/tui /root/.local/state/opencode/tui
COPY config/share/auth.json /root/.local/share/opencode/auth.json

# Install plugin dependencies if package.json exists
WORKDIR /root/.config/opencode
RUN if [ -f package.json ]; then npm install; fi

# Copy the dev projects tar file (all three projects, without node_modules)
COPY dev-projects-all-v19.tar.gz /tmp/dev-projects.tar.gz

# Create workspace directory and extract all projects
RUN mkdir -p /workspace && \
    cd /workspace && \
    tar -xzf /tmp/dev-projects.tar.gz && \
    rm /tmp/dev-projects.tar.gz

# Configure git safe directories for all projects
RUN git config --global --add safe.directory /workspace/lingking-purple/front && \
    git config --global --add safe.directory /workspace/lingking-purple/back && \
    git config --global --add safe.directory /workspace/students-blue/front && \
    git config --global --add safe.directory /workspace/students-blue/back && \
    git config --global --add safe.directory /workspace/teachers-blue/front && \
    git config --global --add safe.directory /workspace/teachers-blue/back

# Add missing peer dependencies to package.json
RUN sed -i '/\"voice-activity-detection\": \".*\"/a\    \"white-web-sdk\": \"^2.16.52\",' /workspace/teachers-blue/front/package.json && \
    sed -i '/\"white-web-sdk\": \".*\"/a\    \"jspdf\": \"^2.5.1\",' /workspace/teachers-blue/front/package.json && \
    echo "✅ Added missing peer dependencies to package.json"

# Copy .npmrc files to frontend directories (if they exist in the source)
RUN echo "legacy-peer-deps=true" > /workspace/teachers-blue/front/.npmrc && \
    echo "✅ Created .npmrc file for teachers-blue frontend"

# Configure git user and credentials
RUN git config --global user.name "krzjac" && \
    git config --global user.email "krzjac@users.noreply.github.com" && \
    git config --global credential.helper "" && \
    git config --global --add credential.helper "/usr/bin/gh auth git-credential" && \
    git config --global --add credential.helper "!f() { test \"$1\" = get && echo \"username=krzjac\"; }; f"

# Set working directory to workspace root
WORKDIR /workspace

# Copy scripts
COPY welcome.sh /usr/local/bin/welcome.sh
COPY fix-deps.sh /usr/local/bin/fix-deps.sh
COPY full-setup.sh /usr/local/bin/full-setup.sh
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/welcome.sh /usr/local/bin/fix-deps.sh /usr/local/bin/full-setup.sh /usr/local/bin/startup.sh

# Add welcome message to bashrc
RUN echo 'welcome.sh' >> /root/.bashrc

# Default command - use bash for better shell experience
CMD ["/bin/bash"]
