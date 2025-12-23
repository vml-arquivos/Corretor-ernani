# Deploy Rápido com Supabase + Docker

## 🚀 Deploy em 5 Minutos

Este guia mostra como fazer o deploy do sistema usando **Supabase** como banco de dados PostgreSQL.

---

## Pré-requisitos

1. **Conta no Supabase** (gratuita): https://supabase.com
2. **VM/VPS** com Docker instalado
3. **Git** instalado

---

## Passo 1: Criar Projeto no Supabase

1. Acesse https://supabase.com/dashboard
2. Clique em **"New Project"**
3. Preencha:
   - **Name**: `corretor-das-mansoes`
   - **Database Password**: Crie uma senha forte (anote!)
   - **Region**: Escolha a mais próxima (ex: `South America (São Paulo)`)
4. Clique em **"Create new project"**
5. Aguarde 1-2 minutos até o projeto estar pronto

---

## Passo 2: Obter Connection String

1. No dashboard do Supabase, vá em **Settings** → **Database**
2. Role até **Connection string** → **URI**
3. Copie a connection string (formato: `postgresql://postgres:[YOUR-PASSWORD]@db.xxx.supabase.co:5432/postgres`)
4. **Substitua `[YOUR-PASSWORD]`** pela senha que você criou no Passo 1

---

## Passo 3: Clonar o Repositório na VPS

```bash
# Fazer SSH na sua VPS
ssh usuario@IP_DA_VPS

# Clonar o repositório
git clone https://github.com/vml-arquivos/Corretor-ernani.git
cd Corretor-ernani
```

---

## Passo 4: Configurar Variáveis de Ambiente

```bash
# Editar o arquivo .env
nano .env
```

**Preencha as seguintes variáveis OBRIGATÓRIAS:**

```bash
# 1. Connection String do Supabase (do Passo 2)
DATABASE_URL=postgresql://postgres:SUA_SENHA@db.SEU_PROJETO.supabase.co:5432/postgres

# 2. JWT Secret (gere com o comando abaixo)
JWT_SECRET=COLE_AQUI_O_RESULTADO_DO_COMANDO_ABAIXO

# 3. Manus OAuth (obtenha em https://portal.manus.im)
VITE_APP_ID=seu_app_id
OWNER_OPEN_ID=seu_owner_open_id

# 4. Manus Forge API (obtenha em https://portal.manus.im)
BUILT_IN_FORGE_API_KEY=sua_chave_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend
```

**Gerar JWT Secret:**

```bash
openssl rand -base64 32
```

Copie o resultado e cole no `JWT_SECRET`.

**Salvar e sair:**
- Pressione `Ctrl + X`
- Pressione `Y`
- Pressione `Enter`

---

## Passo 5: Executar as Migrations

```bash
# Instalar dependências (apenas na primeira vez)
npm install -g pnpm
pnpm install

# Executar migrations no Supabase
pnpm db:push
```

Você verá algo como:
```
✓ Applying migrations...
✓ Done!
```

---

## Passo 6: Fazer o Deploy com Docker

```bash
# Dar permissão de execução ao script
chmod +x deploy.sh

# Executar o deploy
./deploy.sh
```

O script irá:
1. Fazer o build da imagem Docker
2. Iniciar o container
3. Verificar o health check

---

## Passo 7: Acessar o Sistema

Após o deploy, o sistema estará disponível em:

- **Frontend**: `http://IP_DA_VPS:3000`
- **Admin**: `http://IP_DA_VPS:3000/admin`
- **Simulador**: `http://IP_DA_VPS:3000/simulador-financiamento`
- **Contato**: `http://IP_DA_VPS:3000/contato`

---

## 🔄 Migrar para PostgreSQL Nativo (Futuro)

Quando quiser migrar do Supabase para PostgreSQL nativo na VPS:

1. **Descomente a seção `db` no `docker-compose.yml`**:

```yaml
db:
  image: postgres:16-alpine
  container_name: corretordasmansoes-db
  restart: unless-stopped
  environment:
    POSTGRES_DB: corretordasmansoes
    POSTGRES_USER: corretor
    POSTGRES_PASSWORD: corretorpassword
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
```

2. **Atualize o `DATABASE_URL` no `.env`**:

```bash
DATABASE_URL=postgresql://corretor:corretorpassword@db:5432/corretordasmansoes
```

3. **Descomente o `depends_on` no serviço `app`**:

```yaml
depends_on:
  db:
    condition: service_healthy
```

4. **Faça backup dos dados do Supabase**:

```bash
# Exportar dados do Supabase
pg_dump "postgresql://postgres:senha@db.projeto.supabase.co:5432/postgres" > backup.sql

# Importar para PostgreSQL local
docker exec -i corretordasmansoes-db psql -U corretor -d corretordasmansoes < backup.sql
```

5. **Reinicie o sistema**:

```bash
docker-compose down
docker-compose up -d
```

---

## 📊 Monitorar o Banco de Dados

### No Supabase

Acesse o dashboard do Supabase:
- **Table Editor**: Visualizar e editar dados
- **SQL Editor**: Executar queries SQL
- **Database**: Monitorar conexões e performance

### Com pgAdmin (Opcional)

Se quiser usar pgAdmin para gerenciar o Supabase:

```bash
# Iniciar pgAdmin
docker-compose --profile dev up -d pgadmin

# Acessar: http://IP_DA_VPS:8080
# Email: admin@corretor.com
# Senha: admin
```

Adicione o servidor Supabase no pgAdmin:
- **Host**: `db.SEU_PROJETO.supabase.co`
- **Port**: `5432`
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: Sua senha do Supabase

---

## 🛠️ Comandos Úteis

### Ver logs do container

```bash
docker logs -f corretordasmansoes-app
```

### Reiniciar o sistema

```bash
docker-compose restart
```

### Parar o sistema

```bash
docker-compose down
```

### Atualizar o código

```bash
git pull origin main
docker-compose down
docker-compose up -d --build
```

### Executar migrations manualmente

```bash
pnpm db:push
```

---

## ❓ Troubleshooting

### Erro: "Database connection failed"

1. Verifique se o `DATABASE_URL` está correto no `.env`
2. Verifique se a senha do Supabase está correta
3. Verifique se o projeto do Supabase está ativo

### Erro: "Port 3000 already in use"

```bash
# Verificar o que está usando a porta
sudo lsof -i :3000

# Matar o processo
sudo kill -9 PID
```

### Erro: "Cannot connect to Docker daemon"

```bash
# Iniciar o Docker
sudo systemctl start docker
```

---

## 📞 Suporte

- **Email**: ernanisimiao@hotmail.com
- **WhatsApp**: (61) 98129-9575

---

**Desenvolvido com ❤️ por Manus AI**
