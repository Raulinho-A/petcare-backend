# ---- Build stage ----
FROM node:22 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

RUN npm prune --production

# ---- Runtime stage ----
FROM node:22-slim AS production

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

RUN useradd --user-group --create-home --shell /bin/false appuser
USER appuser

EXPOSE 3500

CMD ["node", "dist/main.js"]