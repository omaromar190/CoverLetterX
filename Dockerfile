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

# Install Wasp
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-linux-x86_64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-linux-arm64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L "$WASP_URL" -o wasp.tar.gz && \
    tar -xzf wasp.tar.gz && \
    mv wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp && \
    rm -rf wasp.tar.gz

# Verify installation
RUN wasp --version

WORKDIR /app
COPY . .

# Build the Wasp app
RUN wasp build

CMD ["wasp", "start"]
