# Corretor das Mansões - Sistema Completo

## 🎯 Sistema de Gestão Imobiliária com IA

Sistema completo de gestão imobiliária com **CRM inteligente**, **simulador de financiamento**, **gestão de aluguel**, **relatórios** e **integrações com IA e N8N**.

---

## 🚀 Deploy Rápido

### Opção 1: Supabase (Recomendado para início)

**Deploy em 5 minutos** com banco de dados PostgreSQL gerenciado:

```bash
git clone https://github.com/vml-arquivos/Corretor-ernani.git
cd Corretor-ernani

# Configurar .env com sua connection string do Supabase
nano .env

# Executar migrations
pnpm install
pnpm db:push

# Deploy com Docker
chmod +x deploy.sh
./deploy.sh
```

📖 **[Guia completo de deploy com Supabase](./DEPLOY_SUPABASE.md)**

### Opção 2: PostgreSQL Nativo na VPS

Para usar PostgreSQL local, descomente a seção `db` no `docker-compose.yml` e siga as instruções em `DEPLOY_INSTRUCTIONS.md`.

---

## ✨ Funcionalidades

### 1. CRM Inteligente com IA
- Gestão completa de leads com perfis e pontuação
- Histórico de interações
- Follow-up automático via N8N
- Análise de perfil de clientes com IA
- Agente de IA (Lívia 3.0) para atendimento

### 2. Simulador de Financiamento Imobiliário
- Cálculo SAC (Sistema de Amortização Constante)
- Cálculo PRICE (Parcelas Constantes)
- Tabela de amortização completa em tempo real
- Captura automática de leads via simulação
- Taxas de juros atualizáveis diariamente

### 3. Sistema de Gestão de Aluguel
- CRUD completo de aluguéis
- Gestão de pagamentos (Boleto, PIX, Transferência, Dinheiro)
- Controle de despesas
- Geração de contratos
- Cálculo automático de comissões
- Notificações de pagamento atrasado via N8N

### 4. Relatórios e Dashboards
- Gráficos interativos (pagamentos, despesas, desempenho)
- Filtros por período
- Exportação para PDF
- Resumo financeiro completo

### 5. Integrações
- **N8N**: Automação de follow-up, notificações, boletos
- **IA (Manus Forge API)**: Atendimento inteligente
- **Blog**: Sistema de blog integrado
- **Analytics**: Rastreamento de eventos
- **AWS S3**: Upload de imagens

---

## 🗂️ Tecnologias

### Frontend
- **React 18** + **TypeScript**
- **TailwindCSS** para estilização
- **Wouter** para roteamento
- **tRPC** para comunicação type-safe com o backend
- **React Hook Form** + **Zod** para validação

### Backend
- **Node.js 22** + **TypeScript**
- **tRPC** para API type-safe
- **Drizzle ORM** para banco de dados
- **PostgreSQL** (Supabase ou nativo)

### DevOps
- **Docker** + **Docker Compose**
- **pnpm** para gerenciamento de pacotes
- **Multi-stage builds** para otimização

---

## 📦 Estrutura do Projeto

```
Corretor-ernani/
├── client/                 # Frontend (React + TypeScript)
│   ├── src/
│   │   ├── pages/         # Páginas públicas e admin
│   │   ├── components/    # Componentes reutilizáveis
│   │   └── lib/           # Utilitários e configurações
├── server/                # Backend (Node.js + tRPC)
│   ├── routers.ts         # Rotas tRPC
│   ├── db.ts              # Funções de banco de dados
│   ├── simulator.ts       # Lógica do simulador
│   ├── rentalManagement.ts # Lógica de aluguel
│   └── n8nIntegration.ts  # Integração com N8N
├── drizzle/               # Schema e migrations
│   └── schema.ts          # Schema PostgreSQL
├── docker-compose.yml     # Configuração Docker
├── Dockerfile             # Imagem Docker
├── deploy.sh              # Script de deploy
└── .env                   # Variáveis de ambiente
```

---

## 🔧 Configuração

### Variáveis de Ambiente Obrigatórias

```bash
# Banco de Dados (Supabase)
DATABASE_URL=postgresql://postgres:senha@db.projeto.supabase.co:5432/postgres

# JWT Secret (gere com: openssl rand -base64 32)
JWT_SECRET=seu_jwt_secret

# Manus OAuth
VITE_APP_ID=seu_app_id
OWNER_OPEN_ID=seu_owner_open_id

# Manus Forge API (IA)
BUILT_IN_FORGE_API_KEY=sua_chave_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend
```

### Variáveis Opcionais

```bash
# N8N
N8N_WEBHOOK_URL=https://seu-n8n.com/webhook
N8N_API_KEY=sua_chave_n8n

# AWS S3
AWS_ACCESS_KEY_ID=sua_chave_aws
AWS_SECRET_ACCESS_KEY=seu_secret_aws
AWS_S3_BUCKET=seu-bucket

# Analytics
VITE_ANALYTICS_WEBSITE_ID=seu_id_analytics
```

---

## 📚 Documentação

- **[DEPLOY_SUPABASE.md](./DEPLOY_SUPABASE.md)** - Guia de deploy com Supabase
- **[DEPLOY_INSTRUCTIONS.md](./DEPLOY_INSTRUCTIONS.md)** - Guia de deploy completo
- **[FINAL_VALIDATION.md](./FINAL_VALIDATION.md)** - Relatório de validação do sistema
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - Documentação da API tRPC

---

## 🛠️ Desenvolvimento Local

```bash
# Instalar dependências
pnpm install

# Configurar .env
cp .env.example .env
# Edite o .env com suas credenciais

# Executar migrations
pnpm db:push

# Iniciar em modo desenvolvimento
pnpm dev
```

Acesse: `http://localhost:3000`

---

## 🔄 Atualizar o Sistema

```bash
# Fazer pull das atualizações
git pull origin main

# Reinstalar dependências (se necessário)
pnpm install

# Executar novas migrations (se houver)
pnpm db:push

# Rebuild e restart
docker-compose down
docker-compose up -d --build
```

---

## 📊 Banco de Dados

### Supabase (Recomendado)

- **Gratuito** até 500 MB
- **Backup automático**
- **Interface web** para gerenciamento
- **Escalável** conforme necessário

### PostgreSQL Nativo

- **Controle total**
- **Sem limites** de armazenamento
- **Requer gerenciamento** manual

---

## 🎨 Páginas

### Públicas
- `/` - Home
- `/imoveis` - Listagem de imóveis
- `/imovel/:id` - Detalhes do imóvel
- `/simulador-financiamento` - Simulador
- `/contato` - Formulário de contato
- `/blog` - Blog
- `/quem-somos` - Sobre

### Admin
- `/admin` - Dashboard
- `/admin/properties` - Gestão de imóveis
- `/admin/leads` - Gestão de leads
- `/admin/clients` - Gestão de clientes
- `/admin/rentals` - Gestão de aluguel
- `/admin/rental-reports` - Relatórios de aluguel
- `/admin/blog` - Gestão de posts

---

## 📞 Contato

- **Email**: ernanisimiao@hotmail.com
- **WhatsApp**: (61) 98129-9575
- **Telefone**: (61) 3254-4464

---

## 📄 Licença

Este projeto é propriedade de **Ernani Nunes - O Corretor das Mansões**.

---

**Desenvolvido com ❤️ por Manus AI**
