# --- Builder stage ---
FROM debian:bookworm-slim as builder

# Install dependencies for Wasp build
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
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L "$WASP_URL" -o /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp

# Build Wasp app -> generates .wasp/out directory
RUN wasp build

# --- Runtime stage ---
FROM debian:bookworm-slim as runtime

# Install only runtime deps
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only built artifacts instead of whole repo
COPY --from=builder /app/.wasp/out /app

# Expose Render’s port (defaults to 10000 if not set)
EXPOSE ${PORT:-10000}

# Start the prebuilt app directly
CMD ["sh", "-c", "cd /app && ./server --port ${PORT:-10000} --host 0.0.0.0"]
