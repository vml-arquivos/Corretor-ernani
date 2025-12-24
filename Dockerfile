# ============================================
# Base com dependências para build
# ============================================
FROM node:22-alpine AS base
WORKDIR /app
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# ============================================
# Dependências completas para o build
# ============================================
FROM base AS dev-deps
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches
RUN pnpm install --frozen-lockfile

# ============================================
# Build do frontend e backend
# ============================================
FROM dev-deps AS builder
COPY client ./client
COPY server ./server
COPY shared ./shared
COPY drizzle ./drizzle
COPY tsconfig.json ./
COPY vite.config.ts ./

RUN pnpm run build

# ============================================
# Produção: apenas dependências runtime
# ============================================
FROM base AS prod-deps
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches
RUN pnpm install --prod --frozen-lockfile

# ============================================
# Imagem Final de Produção
# ============================================
FROM node:22-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000

COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package.json ./package.json
COPY shared ./shared

# Usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "dist/server/index.js"]
