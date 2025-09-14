# ---------- Builder Stage ----------
FROM debian:bookworm-slim AS builder

# Install build dependencies
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

# Copy your app code
WORKDIR /app
COPY . .

# Download Wasp binary based on architecture
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

# ---------- Runtime Stage ----------
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy app and Wasp from builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/wasp /usr/local/bin/wasp

# Ensure Wasp is executable
RUN chmod +x /usr/local/bin/wasp

WORKDIR /app

# Default command
CMD ["bash"]
