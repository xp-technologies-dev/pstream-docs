# Stage 1: Build
FROM node:24-alpine AS builder
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.31.0 --activate

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source
COPY . .

# Build-time configuration (override via docker-compose build.args or --build-arg)
ARG SITE_URL=https://xp-technologies-dev.github.io
ARG BASE_PATH=/pstream-docs
ENV SITE_URL=${SITE_URL}
ENV BASE_PATH=${BASE_PATH}

# Build the site
RUN pnpm build

# Stage 2: Serve
FROM nginx:alpine-slim AS runtime
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
