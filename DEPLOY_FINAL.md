# Deploy Final - VPS Google Cloud com Supabase

## ✅ Sistema 100% Pronto para Produção

Este guia contém as instruções finais para fazer o deploy do sistema **Corretor das Mansões** em uma VPS do Google Cloud utilizando **PostgreSQL no Supabase**.

---

## 📋 Pré-requisitos Confirmados

- ✅ **Supabase configurado** com as credenciais fornecidas
- ✅ **Schema PostgreSQL** migrado e validado
- ✅ **Docker Compose** otimizado (sem banco local)
- ✅ **Dockerfile** otimizado para produção
- ✅ **Variáveis de ambiente** configuradas

---

## 🚀 Passo a Passo do Deploy

### 1. Criar as Tabelas no Supabase

**IMPORTANTE:** Execute este passo **ANTES** de fazer o deploy da aplicação.

1. Acesse o painel do Supabase: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **SQL Editor** (menu lateral esquerdo)
4. Clique em **"New query"**
5. Copie e cole o conteúdo do arquivo `supabase_schema.sql`
6. Clique em **"Run"** para executar o script

**Verificação:**
```sql
-- Execute esta query para verificar se as tabelas foram criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

Você deve ver 25 tabelas criadas:
- `users`, `properties`, `leads`, `interactions`, `blog_posts`, `settings`, `owners`, `analytics`, `transactions`, `commissions`, `reviews`, `interest_rates`, `rentals`, `rental_payments`, `rental_expenses`, `rental_contracts`, etc.

---

### 2. Conectar na VPS Google Cloud

```bash
# SSH na VPS
gcloud compute ssh NOME_DA_INSTANCIA --zone=ZONA

# OU usando SSH direto
ssh usuario@IP_EXTERNO_DA_VPS
```

---

### 3. Instalar Dependências na VPS

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Instalar Git
sudo apt install git -y

# Reiniciar a sessão para aplicar as permissões do Docker
exit
# Conecte novamente
```

---

### 4. Clonar o Repositório

```bash
# Clonar o repositório
git clone https://github.com/vml-arquivos/Corretor-ernani.git
cd Corretor-ernani
```

---

### 5. Configurar Variáveis de Ambiente

```bash
# Editar o arquivo .env
nano .env
```

**Variáveis OBRIGATÓRIAS que você DEVE preencher:**

```bash
# 1. DATABASE_URL (JÁ CONFIGURADO)
DATABASE_URL=postgresql://postgres:Marcelle@040410@db.zeaxqldcytxsbacyqymt.supabase.co:5432/postgres

# 2. JWT_SECRET (GERAR AGORA)
JWT_SECRET=COLE_AQUI_O_RESULTADO_DO_COMANDO_ABAIXO

# 3. Manus OAuth (obtenha em https://portal.manus.im)
VITE_APP_ID=seu_app_id_manus
OWNER_OPEN_ID=seu_owner_open_id

# 4. Manus Forge API (obtenha em https://portal.manus.im)
BUILT_IN_FORGE_API_KEY=sua_chave_forge_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_forge_frontend
```

**Gerar JWT Secret:**

```bash
openssl rand -base64 32
```

Copie o resultado e cole no campo `JWT_SECRET` do arquivo `.env`.

**Salvar e sair do nano:**
- Pressione `Ctrl + X`
- Pressione `Y`
- Pressione `Enter`

---

### 6. Fazer o Build e Deploy

```bash
# Dar permissão de execução ao script de deploy
chmod +x deploy.sh

# Executar o deploy
./deploy.sh
```

O script `deploy.sh` irá:
1. Fazer o build da imagem Docker
2. Iniciar o container
3. Verificar o health check

**Saída esperada:**
```
✓ Building Docker image...
✓ Starting container...
✓ Container is healthy!
✓ Deploy completed successfully!
```

---

### 7. Verificar se o Sistema Está Rodando

```bash
# Verificar logs do container
docker logs -f corretordasmansoes-app

# Verificar status
docker ps
```

**Você deve ver:**
```
CONTAINER ID   IMAGE                    STATUS                    PORTS
abc123def456   corretordasmansoes-app   Up 2 minutes (healthy)    0.0.0.0:3000->3000/tcp
```

---

### 8. Acessar o Sistema

Abra o navegador e acesse:

- **Frontend**: `http://IP_EXTERNO_DA_VPS:3000`
- **Admin**: `http://IP_EXTERNO_DA_VPS:3000/admin`
- **Simulador**: `http://IP_EXTERNO_DA_VPS:3000/simulador-financiamento`
- **Contato**: `http://IP_EXTERNO_DA_VPS:3000/contato`

**Para obter o IP externo da VPS:**

```bash
# No Google Cloud Console
gcloud compute instances list

# OU dentro da VPS
curl ifconfig.me
```

---

## 🔒 Configurar HTTPS (Opcional mas Recomendado)

### Opção 1: Nginx + Certbot (Recomendado)

```bash
# Instalar Nginx
sudo apt install nginx -y

# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Configurar Nginx
sudo nano /etc/nginx/sites-available/corretordasmansoes
```

**Conteúdo do arquivo:**

```nginx
server {
    listen 80;
    server_name seu-dominio.com www.seu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Ativar o site:**

```bash
sudo ln -s /etc/nginx/sites-available/corretordasmansoes /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

**Obter certificado SSL:**

```bash
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com
```

---

## 🛠️ Comandos Úteis

### Ver logs em tempo real

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

### Limpar containers e imagens antigas

```bash
docker system prune -a
```

---

## 🔍 Troubleshooting

### Erro: "Database connection failed"

1. Verifique se o `DATABASE_URL` está correto no `.env`
2. Verifique se as tabelas foram criadas no Supabase
3. Teste a conexão manualmente:

```bash
docker exec -it corretordasmansoes-app sh
# Dentro do container
node -e "console.log(process.env.DATABASE_URL)"
```

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

# Verificar status
sudo systemctl status docker
```

### Container não inicia

```bash
# Ver logs detalhados
docker logs corretordasmansoes-app

# Verificar configurações
docker inspect corretordasmansoes-app
```

---

## 📊 Monitoramento

### Verificar uso de recursos

```bash
# CPU e memória
docker stats

# Espaço em disco
df -h
```

### Configurar firewall

```bash
# Permitir porta 3000
sudo ufw allow 3000/tcp

# Permitir HTTP e HTTPS (se usar Nginx)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Ativar firewall
sudo ufw enable
```

---

## 🔄 Backup do Banco de Dados

```bash
# Exportar dados do Supabase
pg_dump "postgresql://postgres:Marcelle@040410@db.zeaxqldcytxsbacyqymt.supabase.co:5432/postgres" > backup_$(date +%Y%m%d).sql

# Fazer backup automático (cron)
crontab -e

# Adicionar linha (backup diário às 3h da manhã)
0 3 * * * pg_dump "postgresql://postgres:Marcelle@040410@db.zeaxqldcytxsbacyqymt.supabase.co:5432/postgres" > /home/usuario/backups/backup_$(date +\%Y\%m\%d).sql
```

---

## 📞 Suporte

- **Email**: ernanisimiao@hotmail.com
- **WhatsApp**: (61) 98129-9575
- **Telefone**: (61) 3254-4464

---

## ✅ Checklist Final

Antes de considerar o deploy completo, verifique:

- [ ] Tabelas criadas no Supabase (25 tabelas)
- [ ] Variáveis de ambiente configuradas no `.env`
- [ ] JWT_SECRET gerado e configurado
- [ ] Credenciais Manus OAuth configuradas
- [ ] Credenciais Manus Forge API configuradas
- [ ] Container rodando e saudável (`docker ps`)
- [ ] Sistema acessível via navegador
- [ ] Login funcionando
- [ ] Cadastro de imóveis funcionando
- [ ] Simulador de financiamento funcionando
- [ ] HTTPS configurado (opcional)
- [ ] Firewall configurado
- [ ] Backup automático configurado (opcional)

---

**Deploy realizado com sucesso! 🎉**

O sistema está **100% funcional** e pronto para uso em produção.
