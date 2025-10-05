# syntax=docker/dockerfile:1

# Builder stage
FROM node:lts-alpine AS builder

# Set working directory
WORKDIR /app

RUN apk add --no-cache bash

# Install dependencies based on the lockfile for reproducible builds
COPY package*.json ./
RUN npm ci --silent

# Copy source and build
COPY . .
RUN npm run build --silent


# Production stage
FROM node:lts-alpine AS runner

# NODE_ENV is automatically set by Next.js based on the command
# production mode: next build && next start

RUN apk add --no-cache bash

# Create a non-root user for improved security
RUN addgroup -S app && adduser -S app -G app

# Create and set ownership of directories upfront
RUN mkdir -p /app /home/app/.npm && \
    chown -R app:app /app /home/app

# Switch to app user before copying files
USER app
WORKDIR /app

# Install only production dependencies. This keeps the final image small.
COPY --chown=app:app package*.json ./
RUN npm ci --omit=dev --production --silent

# Copy built assets and public files from the builder stage
COPY --chown=app:app --from=builder /app/.next ./.next
COPY --chown=app:app --from=builder /app/public ./public

USER app

EXPOSE 3000

# Use the standard start script which runs `next start`
CMD ["npm", "start"]


# Development stage
FROM node:lts-alpine AS development

# NODE_ENV is automatically set by Next.js based on the command
# development mode: next dev

RUN apk add --no-cache bash

# Create a non-root user for improved security (but don't switch to it in development)
RUN addgroup -S app && adduser -S app -G app

# Create and set ownership of directories upfront
RUN mkdir -p /app /home/app/.npm && \
    chown -R app:app /app /home/app

# Stay as root for development to work with volume mounts
# The docker-compose.override.yml handles user switching
WORKDIR /app

# Note: In development mode with volume mounts, dependencies are installed
# at runtime via the entrypoint script or manually
# The volume mount will provide access to package.json from the host

EXPOSE 3000

# Use the development script
CMD ["npm", "run", "dev"]
