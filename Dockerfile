# ─────────────────────────────────────────────────────────────
# Stage 1 — Build (using Node to validate / process assets)
# ─────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy project files
COPY . .

# (Optional) install any build tools if needed in the future
# RUN npm ci && npm run build

# ─────────────────────────────────────────────────────────────
# Stage 2 — Serve with Nginx (lightweight production image)
# ─────────────────────────────────────────────────────────────
FROM nginx:1.25-alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static site files from builder
COPY --from=builder /app /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
