# --- Builder stage ---
FROM debian:12 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy app source
COPY . .

# Install Wasp CLI
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
    rm wasp.tar.gz

# Build Wasp app -> generates .wasp/out directory
RUN wasp build


# --- Runtime stage ---
FROM debian:12 AS runtime

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app/.wasp/out /app

# Expose port (Wasp defaults to 3000 unless changed in main.wasp)
EXPOSE 3000

# Run Wasp app
CMD ["./server"]
