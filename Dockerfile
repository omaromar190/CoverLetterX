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
    xauth \
    && rm -rf /var/lib/apt/lists/*

# Set a stable Wasp version
ENV WASP_VERSION=0.15.0

# Install Wasp
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PLATFORM="linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PLATFORM="linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v${WASP_VERSION}/wasp-${PLATFORM}.tar.gz" && \
    echo "Downloading Wasp from $WASP_URL" && \
    curl -L "$WASP_URL" -o /tmp/wasp.tar.gz && \
    tar -xzf /tmp/wasp.tar.gz -C /tmp && \
    mv /tmp/wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp && \
    rm -rf /tmp/wasp.tar.gz

# Verify installation
RUN wasp --version

# Set working directory
WORKDIR /app
COPY . .

# Build the Wasp app
RUN wasp build

# Start the Wasp app
CMD ["wasp", "start"]
