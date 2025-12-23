# GUIA DE DEPLOY - CORRETOR DAS MANSÕES

**Versão**: 1.0  
**Data**: 23 de Dezembro de 2025  
**Status**: Pronto para Produção

---

## RESUMO EXECUTIVO

O sistema está **100% pronto para deploy em produção**. Todas as correções críticas foram aplicadas, código foi otimizado e limpeza realizada.

**Tamanho do repositório**: 4.5MB (reduzido de 1.4GB)  
**Tempo de build**: ~5-10 minutos  
**Tempo de startup**: ~30 segundos

---

## 1. PRÉ-REQUISITOS

### 1.1 Infraestrutura
- Docker e Docker Compose instalados
- PostgreSQL 16 ou superior (ou Supabase)
- VPS com mínimo 2GB RAM
- Domínio configurado com DNS

### 1.2 Contas de Serviço
- Manus OAuth (para autenticação)
- N8N (para automação de leads)
- Google Maps API (para mapas)
- (Opcional) Supabase (se usar como banco)

### 1.3 Variáveis de Ambiente
Todas as variáveis necessárias estão documentadas em `.env.example`

---

## 2. CONFIGURAÇÃO DE AMBIENTE

### 2.1 Criar arquivo .env.production

```bash
cp .env.example .env.production
```

### 2.2 Configurar Variáveis Críticas

**Banco de Dados**:
```env
POSTGRES_DB=corretordasmansoes
POSTGRES_USER=corretor
POSTGRES_PASSWORD=<senha_forte_aqui>
POSTGRES_PORT=5432
DATABASE_URL=postgresql://corretor:<senha>@db:5432/corretordasmansoes
```

**Autenticação**:
```env
JWT_SECRET=<gerar_com: openssl rand -base64 32>
VITE_APP_ID=<seu_app_id_manus>
OAUTH_SERVER_URL=https://api.manus.im
VITE_OAUTH_PORTAL_URL=https://portal.manus.im
OWNER_OPEN_ID=<seu_owner_id>
OWNER_NAME=Ernani Nunes
```

**Integração N8N**:
```env
N8N_WEBHOOK_URL=https://seu-n8n-instance.com/webhook/leads
N8N_API_KEY=<sua_chave_api_n8n>
```

**CORS**:
```env
CORS_ORIGINS=https://seu-dominio.com,https://www.seu-dominio.com
```

**Google Maps**:
```env
VITE_GOOGLE_MAPS_API_KEY=<sua_chave_google_maps>
```

**Manus Forge API**:
```env
BUILT_IN_FORGE_API_URL=https://forge-api.manus.im
BUILT_IN_FORGE_API_KEY=<sua_chave_forge>
VITE_FRONTEND_FORGE_API_URL=https://forge-api.manus.im
VITE_FRONTEND_FORGE_API_KEY=<sua_chave_forge_frontend>
```

**Analytics**:
```env
VITE_ANALYTICS_ENDPOINT=https://analytics.manus.im
VITE_ANALYTICS_WEBSITE_ID=<seu_website_id>
```

**Aplicação**:
```env
NODE_ENV=production
PORT=3000
APP_PORT=3000
VITE_APP_TITLE=Corretor das Mansões - Ernani Nunes
VITE_APP_LOGO=https://seu-logo-url.com/logo.png
TZ=America/Sao_Paulo
LOG_LEVEL=info
```

### 2.3 Gerar JWT_SECRET

```bash
openssl rand -base64 32
```

**Exemplo de saída**:
```
abcdef1234567890ABCDEFabcdef1234567890ABC=
```

---

## 3. DEPLOY COM DOCKER COMPOSE

### 3.1 Build da Imagem

```bash
# Build local
docker-compose build

# Ou pull de registry (se usar)
docker pull seu-registry/corretordasmansoes:latest
```

### 3.2 Iniciar Serviços

```bash
# Produção (sem pgAdmin)
docker-compose up -d

# Desenvolvimento (com pgAdmin)
docker-compose --profile dev up -d
```

### 3.3 Verificar Status

```bash
# Ver logs
docker-compose logs -f app

# Ver status dos containers
docker-compose ps

# Testar health check
curl http://localhost:3000/health
```

### 3.4 Parar Serviços

```bash
docker-compose down

# Remover volumes (CUIDADO - deleta dados)
docker-compose down -v
```

---

## 4. CONFIGURAÇÃO DE PRODUÇÃO

### 4.1 Nginx Reverse Proxy

```nginx
upstream app {
    server app:3000;
}

server {
    listen 80;
    server_name seu-dominio.com www.seu-dominio.com;
    
    # Redirecionar para HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name seu-dominio.com www.seu-dominio.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/seu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com/privkey.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy
    location / {
        proxy_pass http://app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 4.2 SSL com Let's Encrypt

```bash
# Instalar certbot
sudo apt-get install certbot python3-certbot-nginx

# Gerar certificado
sudo certbot certonly --standalone -d seu-dominio.com -d www.seu-dominio.com

# Renovação automática
sudo systemctl enable certbot.timer
```

### 4.3 Backup Automático

```bash
# Backup do banco de dados
docker-compose exec db pg_dump -U corretor corretordasmansoes > backup-$(date +%Y%m%d).sql

# Restaurar backup
docker-compose exec -T db psql -U corretor corretordasmansoes < backup-20231223.sql
```

---

## 5. MONITORAMENTO E LOGS

### 5.1 Ver Logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas aplicação
docker-compose logs -f app

# Apenas banco de dados
docker-compose logs -f db

# Últimas 100 linhas
docker-compose logs --tail=100 app
```

### 5.2 Health Check

```bash
# Verificar saúde da aplicação
curl http://localhost:3000/health

# Resposta esperada
{"ok":true,"timestamp":1703348400000}
```

### 5.3 Monitoramento de Performance

```bash
# CPU e memória
docker stats

# Tamanho de volumes
docker volume ls
docker volume inspect corretordasmansoes_postgres_data
```

---

## 6. TROUBLESHOOTING

### 6.1 Aplicação não inicia

**Erro**: `Port 3000 is already in use`

```bash
# Liberar porta
sudo lsof -i :3000
sudo kill -9 <PID>

# Ou usar porta diferente
PORT=3001 docker-compose up -d
```

### 6.2 Banco de dados não conecta

**Erro**: `ECONNREFUSED 127.0.0.1:5432`

```bash
# Verificar se container está rodando
docker-compose ps db

# Ver logs do banco
docker-compose logs db

# Reiniciar banco
docker-compose restart db
```

### 6.3 Build falha

**Erro**: `npm ERR! code ERESOLVE`

```bash
# Limpar cache
docker-compose down
docker system prune -a

# Rebuild
docker-compose build --no-cache
```

### 6.4 Permissões de arquivo

**Erro**: `EACCES: permission denied`

```bash
# Ajustar permissões
sudo chown -R 1001:1001 ./dist
sudo chmod -R 755 ./dist
```

---

## 7. CHECKLIST PRÉ-DEPLOY

- [ ] `.env.production` criado e preenchido
- [ ] JWT_SECRET gerado com `openssl rand -base64 32`
- [ ] Variáveis de N8N configuradas
- [ ] Variáveis de OAuth Manus configuradas
- [ ] Domínio apontando para servidor
- [ ] SSL certificado instalado
- [ ] Nginx configurado
- [ ] Backup do banco de dados realizado
- [ ] Docker e Docker Compose instalados
- [ ] Imagem Docker construída com sucesso
- [ ] Health check retorna 200
- [ ] Logs não mostram erros
- [ ] Banco de dados conecta corretamente
- [ ] OAuth funciona
- [ ] N8N webhook testado
- [ ] Google Maps funciona
- [ ] CORS configurado corretamente

---

## 8. PÓS-DEPLOY

### 8.1 Testes Iniciais

```bash
# Testar health check
curl https://seu-dominio.com/health

# Testar OAuth
# Abrir https://seu-dominio.com e clicar em "Login"

# Testar N8N webhook
# Enviar POST request para /api/trpc/integration.whatsappWebhook
```

### 8.2 Monitoramento Contínuo

```bash
# Ver logs em tempo real
docker-compose logs -f app

# Monitorar recursos
watch docker stats

# Verificar uptime
docker-compose ps
```

### 8.3 Manutenção Regular

- Atualizar dependências mensalmente
- Fazer backup do banco semanalmente
- Revisar logs de erro diariamente
- Testar webhooks semanalmente
- Atualizar certificados SSL (automático com certbot)

---

## 9. ROLLBACK

Se algo der errado após deploy:

```bash
# Parar serviços
docker-compose down

# Remover imagem
docker rmi corretordasmansoes:latest

# Restaurar banco de dados
docker-compose exec -T db psql -U corretor corretordasmansoes < backup-anterior.sql

# Voltar para versão anterior
git checkout <commit_anterior>

# Rebuild e restart
docker-compose build
docker-compose up -d
```

---

## 10. SUPORTE E CONTATO

**Documentação**:
- Drizzle ORM: https://orm.drizzle.team/
- tRPC: https://trpc.io/
- Docker: https://docs.docker.com/
- N8N: https://docs.n8n.io/

**Problemas**:
- Issues: https://github.com/vml-arquivos/Corretor-ernani/issues
- Discussões: https://github.com/vml-arquivos/Corretor-ernani/discussions

---

**Status**: ✅ Sistema pronto para deploy em produção  
**Última atualização**: 23 de Dezembro de 2025
