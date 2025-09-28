# ---- Base image ----
FROM ubuntu:22.04

# ---- Environment ----
ENV DEBIAN_FRONTEND=noninteractive
ENV WASP_VERSION=0.15.0

# ---- Install dependencies ----
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    xz-utils \
    build-essential \
    git \
    pkg-config \
    zlib1g-dev \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
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
    mkdir -p /tmp/wasp && \
    tar -xzf /tmp/wasp.tar.gz -C /tmp/wasp && \
    mv /tmp/wasp/wasp /usr/local/bin/wasp 2>/dev/null || mv /tmp/wasp/*/wasp /usr/local/bin/wasp && \
    chmod +x /usr/local/bin/wasp && \
    rm -rf /tmp/wasp /tmp/wasp.tar.gz

# ---- Verify installation ----
RUN wasp --version

# ---- Set working directory ----
WORKDIR /app

# ---- Default command ----
CMD [ "wasp", "help" ]
