FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libpq-dev \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Wasp (latest release with fallback to v0.15.0)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PLATFORM="linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PLATFORM="linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    LATEST_URL=$(curl -s https://api.github.com/repos/wasp-lang/wasp/releases/latest \
        | grep "browser_download_url" \
        | grep "$PLATFORM" \
        | cut -d '"' -f 4) && \
    if [ -z "$LATEST_URL" ]; then \
        echo "⚠️  GitHub API failed, falling back to v0.15.0" && \
        LATEST_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-$PLATFORM.tar.gz"; \
    fi && \
    curl -L "$LATEST_URL" -o wasp.tar.gz && \
    tar -xzf wasp.tar.gz && \
    mv wasp-*/wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp && \
    rm -rf wasp.tar.gz wasp-*

# Verify installation
RUN wasp --version

WORKDIR /app
COPY . .

# Build the Wasp app
RUN wasp build

CMD ["wasp", "start"]
