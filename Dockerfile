# --- Builder stage ---
FROM debian:bookworm-slim AS builder

# Install dependencies for building
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY . .

# Install correct Wasp binary (multi-arch)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        WASP_FILE="wasp-0.15.0-linux-x86_64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        WASP_FILE="wasp-0.15.0-linux-aarch64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L "https://github.com/wasp-lang/wasp/releases/download/v0.15.0/$WASP_FILE" -o /tmp/wasp.tar.gz && \
    tar -xzf /tmp/wasp.tar.gz -C /tmp && \
    mv /tmp/wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp

# Build Wasp app -> generates .wasp/out directory
RUN wasp build

# --- Runtime stage ---
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy generated app from builder
COPY --from=builder /app/.wasp/out /app

# Install server dependencies
RUN pip3 install -r requirements.txt || true

# Expose port
EXPOSE 3000

# Start the app
CMD ["./start.sh"]
