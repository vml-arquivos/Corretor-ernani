# Corretor das Mansões - Sistema de Gestão de Imóveis

**Versão**: 1.0.0  
**Status**: ✅ Pronto para Produção  
**Última Atualização**: 23 de Dezembro de 2025

---

## 📋 Visão Geral

Sistema completo de gestão de imóveis integrado com WhatsApp/N8N, OAuth Manus, PostgreSQL e Google Maps. Desenvolvido com React 19, tRPC, Drizzle ORM e Docker.

**Funcionalidades principais**:
- 🏠 Gestão completa de imóveis
- 👥 Gestão de leads e clientes
- 💬 Integração com WhatsApp via N8N
- 🗺️ Mapas interativos com Google Maps
- 📊 Dashboard com analytics
- 🔐 Autenticação segura com OAuth
- 📱 Interface responsiva

---

## 🚀 Quick Start

### Desenvolvimento Local

```bash
# 1. Clonar repositório
git clone https://github.com/vml-arquivos/Corretor-ernani.git
cd Corretor-ernani

# 2. Instalar dependências
pnpm install

# 3. Configurar variáveis de ambiente
cp .env.example .env.local

# 4. Iniciar servidor de desenvolvimento
pnpm dev

# 5. Abrir http://localhost:5173
```

### Produção com Docker

```bash
# 1. Configurar variáveis
cp .env.example .env.production
# Editar .env.production com valores reais

# 2. Build e deploy
docker-compose up -d

# 3. Verificar saúde
curl http://localhost:3000/health
```

---

## 📦 Stack Tecnológico

| Categoria | Tecnologia | Versão |
|-----------|-----------|--------|
| **Frontend** | React | 19.1.1 |
| **Styling** | TailwindCSS | 4.1.14 |
| **Build** | Vite | 7.1.7 |
| **Backend** | Express | 4.21.2 |
| **API** | tRPC | 11.6.0 |
| **Database** | PostgreSQL | 16 |
| **ORM** | Drizzle | 0.44.6 |
| **Auth** | OAuth Manus | Latest |
| **Maps** | Google Maps API | Latest |
| **Automation** | N8N | Latest |
| **Container** | Docker | Latest |

---

## 🗂️ Estrutura do Projeto

```
.
├── client/                  # Frontend React
│   ├── src/
│   │   ├── components/     # Componentes reutilizáveis
│   │   ├── pages/          # Páginas da aplicação
│   │   ├── _core/          # Hooks e utilitários
│   │   └── App.tsx         # Componente principal
│   └── index.html
├── server/                  # Backend Express + tRPC
│   ├── _core/              # Configuração central
│   ├── routers.ts          # Definição de rotas tRPC
│   ├── db.ts               # Funções de banco de dados
│   └── *.test.ts           # Testes
├── shared/                  # Código compartilhado
│   ├── const.ts            # Constantes
│   └── types.ts            # Tipos TypeScript
├── drizzle/                # Migrações e schema
│   ├── schema.ts           # Definição de tabelas
│   └── migrations/         # Histórico de migrações
├── docker-compose.yml      # Orquestração de containers
├── Dockerfile              # Build da imagem
├── package.json            # Dependências
├── tsconfig.json           # Configuração TypeScript
├── vite.config.ts          # Configuração Vite
└── drizzle.config.ts       # Configuração Drizzle
```

---

## 🔧 Configuração

### Variáveis de Ambiente Obrigatórias

```env
# Banco de Dados
DATABASE_URL=postgresql://user:password@host:port/database

# Autenticação
JWT_SECRET=<gerar com: openssl rand -base64 32>
VITE_APP_ID=seu_app_id
OAUTH_SERVER_URL=https://api.manus.im
OWNER_OPEN_ID=seu_owner_id
OWNER_NAME=Ernani Nunes

# N8N
N8N_WEBHOOK_URL=https://seu-n8n.com/webhook/leads
N8N_API_KEY=sua_chave_api

# Google Maps
VITE_GOOGLE_MAPS_API_KEY=sua_chave_google

# Manus Forge API
BUILT_IN_FORGE_API_URL=https://forge-api.manus.im
BUILT_IN_FORGE_API_KEY=sua_chave
```

Veja `.env.example` para lista completa.

---

## 📚 Documentação

- **[GUIA_DEPLOY.md](./GUIA_DEPLOY.md)** - Instruções completas de deploy
- **[VALIDACAO_INTEGRACOES.md](./VALIDACAO_INTEGRACOES.md)** - Detalhes de integrações
- **[ANALISE_COMPLETA.md](./ANALISE_COMPLETA.md)** - Análise técnica do sistema

---

## 🧪 Testes

```bash
# Executar todos os testes
pnpm test

# Modo watch
pnpm test:watch

# Cobertura
pnpm test:coverage
```

---

## 📝 Scripts Disponíveis

```bash
# Desenvolvimento
pnpm dev              # Iniciar servidor de desenvolvimento
pnpm build            # Build para produção
pnpm start            # Iniciar servidor de produção

# Qualidade de código
pnpm format           # Formatar código com Prettier
pnpm lint             # Verificar tipos TypeScript
pnpm type-check       # Verificar tipos

# Banco de dados
pnpm db:push          # Aplicar migrações
pnpm db:studio        # Abrir Drizzle Studio

# Testes
pnpm test             # Executar testes
pnpm test:watch       # Modo watch
pnpm test:coverage    # Cobertura de testes
```

---

## 🐳 Docker

### Build Local

```bash
docker build -t corretordasmansoes:latest .
```

### Executar Container

```bash
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e JWT_SECRET=... \
  corretordasmansoes:latest
```

### Docker Compose

```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Logs
docker-compose logs -f app
```

---

## 🔐 Segurança

- ✅ Autenticação OAuth obrigatória
- ✅ JWT tokens seguros
- ✅ Cookies httpOnly
- ✅ CORS configurável
- ✅ Validação de entrada com Zod
- ✅ Proteção contra SQL injection (Drizzle ORM)
- ✅ Usuário non-root em Docker
- ✅ Health checks

---

## 📊 Performance

- **Build**: ~5-10 minutos
- **Startup**: ~30 segundos
- **Tamanho da imagem**: ~400MB
- **Tamanho do repositório**: 4.5MB
- **Queries otimizadas**: Índices de banco de dados
- **Frontend**: Vite + React 19 (rápido)

---

## 🚨 Troubleshooting

### Porta já em uso
```bash
sudo lsof -i :3000
sudo kill -9 <PID>
```

### Banco não conecta
```bash
docker-compose restart db
docker-compose logs db
```

### Build falha
```bash
docker-compose down
docker system prune -a
docker-compose build --no-cache
```

Veja [GUIA_DEPLOY.md](./GUIA_DEPLOY.md#6-troubleshooting) para mais soluções.

---

## 📞 Suporte

- **Issues**: https://github.com/vml-arquivos/Corretor-ernani/issues
- **Discussões**: https://github.com/vml-arquivos/Corretor-ernani/discussions
- **Manus Help**: https://help.manus.im

---

## 📄 Licença

MIT

---

## ✅ Checklist de Produção

- [x] Código otimizado e limpo
- [x] Testes implementados e ativados
- [x] Integrações validadas
- [x] Documentação completa
- [x] Docker configurado
- [x] Variáveis de ambiente documentadas
- [x] Health checks implementados
- [x] CORS configurado
- [x] Segurança validada
- [x] Performance otimizada

**Status**: 🟢 Pronto para Deploy

---

**Desenvolvido com ❤️ para Ernani Nunes**  
**Última atualização**: 23 de Dezembro de 2025
