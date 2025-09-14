# ---------- Builder Stage ----------
FROM debian:bookworm-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    python3 \
    python3-pip \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
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

# ---------- Runtime Stage ----------
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy app files from builder
COPY --from=builder /app /app

# Copy Wasp binary from builder
COPY --from=builder /usr/local/bin/wasp /usr/local/bin/wasp
RUN chmod +x /usr/local/bin/wasp

# Set working directory
WORKDIR /app

# Expose Render default port
ENV PORT=10000
EXPOSE 10000

# Render CMD
CMD ["wasp", "start", "--port", "10000", "--host", "0.0.0.0"]
