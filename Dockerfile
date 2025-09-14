# Use ARM64 Debian slim base
FROM arm64v8/debian:bookworm-slim AS builder

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

# Copy your app
WORKDIR /app
COPY . .

# Download the ARM64 Wasp binary directly
RUN curl -L "https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-arm64" \
    -o /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp

# Set working directory
WORKDIR /app

# Runtime stage
FROM arm64v8/debian:bookworm-slim

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
RUN chmod +x /usr/local/bin/wasp

WORKDIR /app

# Set default command
CMD ["wasp", "start"]
