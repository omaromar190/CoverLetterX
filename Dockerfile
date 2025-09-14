# ---- Builder ----
    FROM debian:12 AS builder

    # Wasp version (override at build time if needed)
    ARG WASP_VERSION=0.15.0
    ENV WASP_VERSION=${WASP_VERSION}
    
    # Install build dependencies
    RUN apt-get update && apt-get install -y \
        curl \
        build-essential \
        gcc \
        g++ \
        make \
        git \
        tar \
        gzip \
        python3 \
        python3-pip \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*
    
    WORKDIR /app
    
    # Copy project files
    COPY . .
    
    # Download and install Wasp
    RUN curl -L "https://github.com/wasp-lang/wasp/releases/download/v${WASP_VERSION}/wasp-${WASP_VERSION}-linux-x86_64.tar.gz" -o /tmp/wasp.tar.gz \
        && tar -xzf /tmp/wasp.tar.gz -C /usr/local/bin \
        && rm /tmp/wasp.tar.gz
    
    # Build the Wasp project
    RUN wasp build
    
    # ---- Runner ----
    FROM debian:12 AS runner
    
    WORKDIR /app
    
    # Copy build output from builder
    COPY --from=builder /app/.wasp/build /app
    
    # Install runtime dependencies
    RUN apt-get update && apt-get install -y \
        curl \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*
    
    EXPOSE 3000
    
    # Start the app
    CMD ["./server"]
    
