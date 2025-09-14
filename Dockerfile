# ===== Stage 1: Builder =====
FROM debian:12 as builder

# Wasp version
ARG WASP_VERSION=0.15.0

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

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Download Wasp binary directly
RUN curl -L "https://github.com/wasp-lang/wasp/releases/download/v${WASP_VERSION}/wasp-${WASP_VERSION}-linux-x86_64" \
    -o /usr/local/bin/wasp \
    && chmod +x /usr/local/bin/wasp

# Optionally build your app here if needed
# RUN wasp build

# ===== Stage 2: Runtime =====
FROM debian:12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy built files and Wasp from builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/wasp /usr/local/bin/wasp

# Ensure Wasp is executable
RUN chmod +x /usr/local/bin/wasp

# Expose port if your app runs a server
EXPOSE 8000

# Default command
CMD ["bash"]
