# ---- Builder ----
    FROM node:20-slim AS builder
    WORKDIR /app
    
    # Install system dependencies (needed for prisma, etc.)
    RUN apt-get update && apt-get install -y openssl python3 make g++ curl && rm -rf /var/lib/apt/lists/*
    
    # Copy project files
    COPY . .
    
    # Install Wasp CLI
    RUN curl -L https://github.com/wasp-lang/wasp/releases/latest/download/wasp-linux-x64 -o /usr/local/bin/wasp \
      && chmod +x /usr/local/bin/wasp
    
    # Build Wasp project
    RUN wasp build
    
    # ---- Runner ----
    FROM node:20-slim
    WORKDIR /app
    
    # Install runtime deps
    RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*
    
    # Copy built app
    COPY --from=builder /app/.wasp/build /app
    
    # Install backend deps
    WORKDIR /app/server
    RUN npm install --omit=dev
    
    EXPOSE 8080
    CMD ["npm", "start"]
    