# Stage 1: Builder
FROM wasp-lang/wasp:latest AS builder
WORKDIR /app
COPY . .
RUN wasp build

# Stage 2: Runtime
FROM node:20-alpine AS runtime
WORKDIR /app

# Install dependencies needed for Prisma
RUN apk add --no-cache openssl

# Copy built application
COPY --from=builder /app/build/ ./

# Copy package.json and install only production dependencies
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
RUN npm ci --only=production

# Expose port
EXPOSE 3001

# Start command
CMD ["node", "server.js"]
