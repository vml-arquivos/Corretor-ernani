# Instruções de Deploy - Corretor das Mansões

## Sistema Completo Implementado

Este repositório contém o **sistema completo** do Corretor das Mansões com as seguintes funcionalidades:

### ✅ Funcionalidades Implementadas

1. **CRM Inteligente**
   - Gestão de leads com perfis e pontuação
   - Histórico de interações
   - Follow-up automático
   - Análise de perfil de clientes

2. **Simulador de Financiamento Imobiliário**
   - Cálculo SAC (Sistema de Amortização Constante)
   - Cálculo PRICE (Parcelas Constantes)
   - Tabela de amortização completa
   - Captura de leads via simulação
   - Taxas de juros atualizáveis diariamente

3. **Sistema de Gestão de Aluguel**
   - Cadastro de aluguéis
   - Gestão de pagamentos (Boleto, PIX, Transferência)
   - Controle de despesas
   - Geração de contratos
   - Cálculo automático de comissões

4. **Relatórios e Dashboards**
   - Relatórios de pagamentos
   - Relatórios de despesas
   - Desempenho por imóvel
   - Análise financeira completa
   - Gráficos interativos

5. **Integrações**
   - **N8N**: Webhooks para automação de follow-up, análise de perfil, notificações
   - **IA (Manus Forge)**: Agentes de IA para atendimento, análise de clientes
   - **Blog**: Sistema de blog integrado
   - **Analytics**: Rastreamento de eventos

---

## Pré-requisitos

### Na VM do Google Cloud

1. **Sistema Operacional**: Ubuntu 20.04 ou superior
2. **Docker**: Versão 20.10 ou superior
3. **Docker Compose**: Versão 2.0 ou superior
4. **Portas Abertas no Firewall**:
   - `80` (HTTP)
   - `443` (HTTPS)
   - `3000` (Porta interna do container)

### Instalação do Docker e Docker Compose

```bash
# Atualizar o sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version
```

---

## Passo a Passo do Deploy

### 1. Clonar o Repositório

```bash
# Fazer SSH na VM do Google Cloud
ssh usuario@IP_DA_VM

# Clonar o repositório
git clone https://github.com/vml-arquivos/Corretor-ernani.git
cd Corretor-ernani
```

### 2. Configurar Variáveis de Ambiente

O arquivo `.env` já está no repositório com valores de exemplo. **Você DEVE preencher este arquivo com suas credenciais reais.**

```bash
# Editar o arquivo .env
nano .env
```

**Variáveis Obrigatórias:**

```bash
# Banco de Dados
MYSQL_ROOT_PASSWORD=sua_senha_root_muito_forte
MYSQL_PASSWORD=sua_senha_mysql_muito_forte

# JWT Secret (gerar com: openssl rand -base64 32)
JWT_SECRET=SEGREDO_JWT_GERADO_COM_OPENSSL_AQUI

# Manus OAuth (obter no portal.manus.im)
VITE_APP_ID=seu_app_id_manus
OWNER_OPEN_ID=seu_owner_open_id_manus

# Manus Forge API (para IA)
BUILT_IN_FORGE_API_KEY=sua_chave_api_forge_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_api_forge_frontend

# Analytics (opcional)
VITE_ANALYTICS_WEBSITE_ID=seu_id_analytics

# N8N (opcional - para automações)
N8N_WEBHOOK_URL=https://seu-n8n.com/webhook
N8N_API_KEY=sua_chave_n8n

# AWS S3 (para upload de imagens)
AWS_ACCESS_KEY_ID=sua_chave_aws_aqui
AWS_SECRET_ACCESS_KEY=seu_secret_aws_aqui
AWS_S3_BUCKET=seu-bucket-s3-aqui
```

**Gerar JWT Secret:**

```bash
openssl rand -base64 32
```

### 3. Executar o Deploy

```bash
# Dar permissão de execução ao script
chmod +x deploy.sh

# Executar o deploy
./deploy.sh
```

O script `deploy.sh` irá:
1. Fazer o build da imagem Docker
2. Iniciar os containers (`app` e `db`)
3. Aguardar o banco de dados ficar pronto
4. Executar as migrations do Drizzle ORM
5. Verificar o health check da aplicação

### 4. Verificar o Deploy

```bash
# Verificar se os containers estão rodando
docker ps

# Verificar logs da aplicação
docker logs corretor-app

# Verificar logs do banco de dados
docker logs corretor-db
```

### 5. Acessar o Sistema

- **Frontend**: `http://IP_DA_VM:3000`
- **Admin**: `http://IP_DA_VM:3000/admin`
- **Simulador**: `http://IP_DA_VM:3000/simulador-financiamento`

---

## Configurações Pós-Deploy

### 1. Configurar HTTPS (Recomendado)

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com
```

### 2. Configurar N8N (Opcional)

1. Acesse o N8N em `https://seu-n8n.com`
2. Crie workflows para:
   - Follow-up automático de leads
   - Análise de perfil de clientes
   - Notificações de pagamento atrasado
   - Geração de boletos e PIX
3. Configure os webhooks no arquivo `.env`

### 3. Atualizar Taxas de Juros

Acesse o painel admin em `/admin` e vá para a seção de **Simulador** para atualizar as taxas de juros dos bancos.

### 4. Configurar AWS S3 (Para Upload de Imagens)

1. Crie um bucket no AWS S3
2. Configure as permissões de acesso público
3. Adicione as credenciais no arquivo `.env`

---

## Estrutura de Diretórios

```
Corretor-ernani/
├── client/                 # Frontend (React + TypeScript + TailwindCSS)
│   ├── src/
│   │   ├── pages/         # Páginas públicas e admin
│   │   ├── components/    # Componentes reutilizáveis
│   │   └── lib/           # Utilitários e configurações
├── server/                # Backend (Node.js + tRPC + Drizzle ORM)
│   ├── routers.ts         # Rotas tRPC
│   ├── db.ts              # Funções de banco de dados
│   ├── simulator.ts       # Lógica do simulador
│   ├── rentalManagement.ts # Lógica de aluguel
│   └── n8nIntegration.ts  # Integração com N8N
├── drizzle/               # Schema e migrations do banco
├── docker-compose.yml     # Configuração Docker
├── Dockerfile             # Imagem Docker
├── deploy.sh              # Script de deploy
└── .env                   # Variáveis de ambiente
```

---

## Comandos Úteis

### Parar o Sistema

```bash
docker-compose down
```

### Reiniciar o Sistema

```bash
docker-compose restart
```

### Ver Logs em Tempo Real

```bash
docker-compose logs -f app
```

### Executar Migrations Manualmente

```bash
docker exec -it corretor-app pnpm db:push
```

### Backup do Banco de Dados

```bash
docker exec corretor-db mysqldump -u corretor -p corretordasmansoes > backup.sql
```

### Restaurar Banco de Dados

```bash
docker exec -i corretor-db mysql -u corretor -p corretordasmansoes < backup.sql
```

---

## Troubleshooting

### Erro: "Database not available"

```bash
# Verificar se o MySQL está rodando
docker logs corretor-db

# Reiniciar o banco de dados
docker-compose restart db
```

### Erro: "Port 3000 already in use"

```bash
# Verificar processos usando a porta 3000
sudo lsof -i :3000

# Matar o processo
sudo kill -9 PID
```

### Erro: "Cannot connect to Docker daemon"

```bash
# Iniciar o Docker
sudo systemctl start docker

# Verificar status
sudo systemctl status docker
```

---

## Suporte

Para suporte técnico ou dúvidas sobre o sistema, entre em contato através de:
- **Email**: ernanisimiao@hotmail.com
- **WhatsApp**: (61) 98129-9575

---

## Licença

Este projeto é propriedade de **Ernani Nunes - O Corretor das Mansões**.

---

**Desenvolvido com ❤️ por Manus AI**
