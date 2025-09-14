# ----------------------------
# Stage 1: Builder
# ----------------------------
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    python3 \
    python3-pip \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy app source
COPY . .

# Download Wasp (force x86_64 binary)
RUN curl -L "https://github.com/wasp-lang/wasp/releases/download/v0.15.0/wasp-0.15.0-linux-x86_64" \
    -o /usr/local/bin/wasp && chmod +x /usr/local/bin/wasp

# ----------------------------
# Stage 2: Runtime
# ----------------------------
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

# Make Wasp executable
RUN chmod +x /usr/local/bin/wasp

# Set working directory
WORKDIR /app

# Expose default Render port
ENV PORT=10000
EXPOSE 10000

# Start your app (replace with your actual Wasp command)
CMD ["wasp", "start"]
