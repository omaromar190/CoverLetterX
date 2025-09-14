# ===== Stage 1: Builder =====
FROM debian:12 AS builder

# Set environment variables
ENV WASP_VERSION=0.15.0
WORKDIR /app

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

# Copy project files to builder
COPY . .

# Download and install Wasp
RUN curl -L "https://github.com/wasp-lang/wasp/releases/download/v${WASP_VERSION}/wasp-${WASP_VERSION}-linux-x86_64" \
    -o /usr/local/bin/wasp && chmod +x /usr/local/bin/wasp

# ===== Stage 2: Runtime =====
FROM debian:12-slim AS runtime

WORKDIR /app

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy app from builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/wasp /usr/local/bin/wasp

# Make Wasp executable
RUN chmod +x /usr/local/bin/wasp

# Expose port (adjust if your app uses a different port)
EXPOSE 8000

# Run Wasp server on container start
CMD ["wasp", "start"]
