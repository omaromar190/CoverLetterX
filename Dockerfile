# ---- Base image ----
FROM ubuntu:22.04

# ---- Environment variables ----
ARG WASP_VERSION=0.15.0
ENV DEBIAN_FRONTEND=noninteractive

# ---- Install dependencies ----
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    build-essential \
    git \
    xz-utils \
    libssl-dev \
    libpq-dev \
    pkg-config \
    libffi-dev \
    libsqlite3-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# ---- Install Wasp ----
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PLATFORM="linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PLATFORM="linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    WASP_URL="https://github.com/wasp-lang/wasp/releases/download/v${WASP_VERSION}/wasp-${PLATFORM}.tar.gz" && \
    echo "Downloading Wasp from $WASP_URL" && \
    curl -L "$WASP_URL" -o /tmp/wasp.tar.gz && \
    tar -xzf /tmp/wasp.tar.gz -C /tmp && \
    mv /tmp/wasp-${PLATFORM}/wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp && \
    rm -rf /tmp/wasp.tar.gz /tmp/wasp-${PLATFORM}

# ---- Set working directory ----
WORKDIR /app

# ---- Copy project files ----
COPY . .

# ---- Install project dependencies (example for Node.js) ----
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*
RUN npm install

# ---- Expose port ----
EXPOSE 3000

# ---- Default command ----
CMD ["wasp", "start"]
