# Use Debian as base
FROM debian:bookworm-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    gcc \
    g++ \
    python3 \
    python3-pip \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy your app files
COPY . .

# Download the correct Wasp binary based on architecture
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L "$WASP_URL" -o /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp

# Set Wasp as the default command
ENTRYPOINT ["/usr/local/bin/wasp"]
CMD ["-h"]
