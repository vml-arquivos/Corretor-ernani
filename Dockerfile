 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Dockerfile b/Dockerfile
index c52b86ba03ef09ff2300d801c688e02badadf589..19bc9d10222ae6625c9097ef73c3066c142db9b6 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -1,90 +1,65 @@
 # ============================================
-# STAGE 1: Build do Frontend (Client)
+# Base com dependências para build
 # ============================================
-FROM node:22-alpine AS client-builder
+FROM node:22-alpine AS base
 WORKDIR /app
+ENV PNPM_HOME="/pnpm"
+ENV PATH="$PNPM_HOME:$PATH"
+RUN corepack enable
 
-# Copiar package.json e lock files
+# ============================================
+# Dependências completas para o build
+# ============================================
+FROM base AS dev-deps
 COPY package.json pnpm-lock.yaml ./
 COPY patches ./patches
+RUN pnpm install --frozen-lockfile
 
-# Instalar pnpm e dependências
-RUN npm install -g pnpm@latest && \
-    pnpm install --frozen-lockfile
-
-# Copiar código fonte necessário para o build do cliente
+# ============================================
+# Build do frontend e backend
+# ============================================
+FROM dev-deps AS builder
 COPY client ./client
+COPY server ./server
 COPY shared ./shared
+COPY drizzle ./drizzle
 COPY tsconfig.json ./
 COPY vite.config.ts ./
 
-# Build do frontend
-RUN pnpm run build:client
+RUN pnpm run build
 
 # ============================================
-# STAGE 2: Build do Backend (Server)
+# Produção: apenas dependências runtime
 # ============================================
-FROM node:22-alpine AS server-builder
-WORKDIR /app
-
-# Copiar package.json e lock files
+FROM base AS prod-deps
 COPY package.json pnpm-lock.yaml ./
 COPY patches ./patches
-
-# Instalar pnpm e dependências
-RUN npm install -g pnpm@latest && \
-    pnpm install --frozen-lockfile
-
-# Copiar código fonte do servidor
-COPY server ./server
-COPY drizzle ./drizzle
-COPY shared ./shared
-COPY tsconfig.json ./
-COPY vite.config.ts ./
-
-# Build do backend
-RUN pnpm run build:server
+RUN pnpm install --prod --frozen-lockfile
 
 # ============================================
-# STAGE 3: Imagem Final de Produção
+# Imagem Final de Produção
 # ============================================
-FROM node:22-alpine
+FROM node:22-alpine AS runtime
 WORKDIR /app
 
-# Instalar pnpm globalmente
-RUN npm install -g pnpm@latest
-
-# Copiar package.json e instalar apenas prod dependencies
-COPY package.json pnpm-lock.yaml ./
-COPY patches ./patches
-RUN pnpm install --prod --frozen-lockfile
-
-# Copiar builds do frontend e backend
-COPY --from=client-builder /app/dist/client ./dist/client
-COPY --from=server-builder /app/dist/server ./dist/server
+ENV NODE_ENV=production \
+    PORT=3000
 
-# Copiar arquivos necessários para runtime
-COPY drizzle ./drizzle
+COPY --from=prod-deps /app/node_modules ./node_modules
+COPY --from=builder /app/dist ./dist
+COPY package.json ./package.json
 COPY shared ./shared
-COPY server/_core ./server/_core
 
-# Criar usuário não-root para segurança
+# Usuário não-root
 RUN addgroup -g 1001 -S nodejs && \
     adduser -S nodejs -u 1001 && \
     chown -R nodejs:nodejs /app
 
 USER nodejs
 
-# Expor porta
 EXPOSE 3000
 
-# Variáveis de ambiente padrão
-ENV NODE_ENV=production \
-    PORT=3000
-
-# Health check
 HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
     CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"
 
-# Comando de inicialização
 CMD ["node", "dist/server/index.js"]
 
EOF
)
