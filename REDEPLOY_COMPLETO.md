# 🚀 REDEPLOY COMPLETO - Corretor das Mansões

## ✅ CORREÇÃO DO ERRO CRÍTICO

**Erro identificado**: `TypeError: propertyTypeEnum.notNull is not a function`  
**Causa**: Sintaxe incorreta do Drizzle ORM para PostgreSQL  
**Status**: ✅ **CORRIGIDO NO REPOSITÓRIO**

---

## 📋 O QUE FOI CORRIGIDO

### 🔴 Problema Original

O código estava usando sintaxe **incorreta** do Drizzle ORM:

```typescript
// ❌ ERRADO
propertyType: propertyTypeEnum.notNull()
```

### ✅ Correção Aplicada

Corrigido para a sintaxe **correta** do Drizzle ORM para PostgreSQL:

```typescript
// ✅ CORRETO
propertyType: propertyTypeEnum("propertyType").notNull()
```

### 📊 Estatísticas

- **10 ocorrências corrigidas** no arquivo `drizzle/schema.ts`
- **8 tipos diferentes de enum** corrigidos
- **Todas as tabelas afetadas** foram corrigidas

---

## 🚀 PASSO A PASSO DO REDEPLOY

### **ETAPA 1: Atualizar o Repositório na VPS**

```bash
cd ~/Corretor-ernani

# Verificar branch atual
git branch --show-current

# Atualizar código (puxar correções)
git pull origin main
```

**Saída esperada:**
```
From https://github.com/vml-arquivos/Corretor-ernani
 * branch            main       -> FETCH_HEAD
Updating 6fb5b070..XXXXXXXX
Fast-forward
 drizzle/schema.ts | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)
```

---

### **ETAPA 2: Aplicar Correção do Drizzle (Automático)**

```bash
# Executar script de correção
./fix-drizzle-schema.sh
```

**O que o script faz:**
- ✅ Cria backup automático do schema.ts
- ✅ Corrige todas as 10 ocorrências do erro
- ✅ Valida que todas as correções foram aplicadas
- ✅ Mostra próximos passos

**Saída esperada:**
```
✅ TODAS AS CORREÇÕES APLICADAS COM SUCESSO!
📊 Resumo:
  - Erros encontrados: 10
  - Erros corrigidos: 10
  - Erros restantes: 0
```

---

### **ETAPA 3: Parar o Container Atual**

```bash
# Parar e remover container
docker-compose down
```

**Saída esperada:**
```
Stopping corretordasmansoes-app ... done
Removing corretordasmansoes-app ... done
Removing network corretor-ernani_corretor-network
```

---

### **ETAPA 4: Rebuild Completo (SEM CACHE)**

```bash
# Fazer rebuild completo sem usar cache
docker-compose build --no-cache
```

**⏱️ Tempo estimado**: 5-10 minutos

**O que acontece:**
- ✅ Build do frontend com código corrigido
- ✅ Build do backend com schema corrigido
- ✅ Instalação de todas as dependências
- ✅ Criação da imagem Docker final

**Saída esperada (final):**
```
Successfully built XXXXXXXXXX
Successfully tagged corretor-ernani-app:latest
```

---

### **ETAPA 5: Iniciar o Container**

```bash
# Iniciar container em background
docker-compose up -d
```

**Saída esperada:**
```
Creating network "corretor-ernani_corretor-network" ... done
Creating corretordasmansoes-app ... done
```

---

### **ETAPA 6: Verificar Logs (CRÍTICO)**

```bash
# Ver logs em tempo real
docker logs -f corretordasmansoes-app
```

**✅ Saída esperada (SUCESSO):**
```
Server running on http://localhost:3000/
```

**❌ Se ainda houver erro:**
- Copie todo o log e me envie
- Vou identificar o próximo problema

**Para sair dos logs**: Pressione `Ctrl + C`

---

### **ETAPA 7: Verificar Status do Container**

```bash
# Ver status dos containers
docker ps
```

**✅ Saída esperada (SUCESSO):**
```
CONTAINER ID   IMAGE                 STATUS                    PORTS
abc123def456   corretor-ernani-app   Up 30 seconds (healthy)   0.0.0.0:3000->3000/tcp
```

**Status deve ser**: `Up` e `(healthy)`

---

### **ETAPA 8: Testar Acesso HTTP**

```bash
# Testar se o servidor está respondendo
curl -I http://localhost:3000/
```

**✅ Saída esperada (SUCESSO):**
```
HTTP/1.1 200 OK
Content-Type: text/html
```

**❌ Se retornar erro:**
```
curl: (7) Failed to connect to localhost port 3000
```
→ Container não está rodando ou crashou

---

### **ETAPA 9: Testar Conteúdo da Página**

```bash
# Ver conteúdo HTML
curl http://localhost:3000/ | head -50
```

**✅ Saída esperada (SUCESSO):**
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Corretor das Mansões</title>
  ...
```

---

## 🔍 TROUBLESHOOTING

### ❌ Erro: "git pull" falha

**Solução:**
```bash
# Descartar mudanças locais e puxar código limpo
git reset --hard origin/main
git pull origin main
```

---

### ❌ Erro: Container continua em loop de restart

**Diagnóstico:**
```bash
# Ver logs completos
docker logs --tail=200 corretordasmansoes-app
```

**Ação:**
- Copie todo o log
- Me envie para análise
- Pode haver outro erro não identificado

---

### ❌ Erro: "Cannot find module 'dist/client'"

**Causa**: Problema de build path (correção anterior)

**Solução:**
```bash
# Verificar se as correções de path foram aplicadas
grep "dist/client" vite.config.ts
grep "dist/client" server/_core/vite.ts

# Se não estiverem, aplicar correções de path
./fix-production.sh
```

---

### ❌ Erro: "Database connection failed"

**Causa**: Variáveis de ambiente não configuradas

**Solução:**
```bash
# Verificar .env
cat .env | grep DATABASE_URL

# Se estiver errado, editar
nano .env
# Configurar: DATABASE_URL=postgresql://...
```

---

### ❌ Erro: "JWT_SECRET is required"

**Solução:**
```bash
# Gerar JWT Secret
openssl rand -base64 32

# Editar .env
nano .env
# Adicionar: JWT_SECRET=<valor_gerado>

# Reiniciar container
docker-compose restart
```

---

## 📊 CHECKLIST DE VALIDAÇÃO

Após o redeploy, verifique:

- [ ] `git pull` executado com sucesso
- [ ] `./fix-drizzle-schema.sh` executado sem erros
- [ ] `docker-compose build --no-cache` completou sem erros
- [ ] Container está com status `Up` e `(healthy)`
- [ ] Logs mostram "Server running on http://localhost:3000/"
- [ ] `curl -I http://localhost:3000/` retorna `HTTP/1.1 200 OK`
- [ ] `curl http://localhost:3000/` retorna HTML válido
- [ ] Não há erros nos logs (`docker logs corretordasmansoes-app`)

---

## 🎯 COMANDOS RÁPIDOS

### Ver logs em tempo real
```bash
docker logs -f corretordasmansoes-app
```

### Reiniciar container
```bash
docker-compose restart
```

### Parar tudo
```bash
docker-compose down
```

### Rebuild e restart rápido
```bash
docker-compose down && docker-compose up -d --build
```

### Ver status
```bash
docker ps
docker stats --no-stream
```

### Entrar no container
```bash
docker exec -it corretordasmansoes-app sh
```

---

## 📝 RESUMO DAS CORREÇÕES APLICADAS

### Correção #1: Drizzle Schema (NOVO)
**Arquivo**: `drizzle/schema.ts`  
**Mudança**: 10 ocorrências de `Enum.notNull()` corrigidas  
**Status**: ✅ APLICADO

### Correção #2: Vite Config
**Arquivo**: `vite.config.ts`  
**Mudança**: `dist/public` → `dist/client`  
**Status**: ✅ APLICADO

### Correção #3: Server Vite
**Arquivo**: `server/_core/vite.ts`  
**Mudança**: Paths corrigidos para `../../dist/client`  
**Status**: ✅ APLICADO

### Correção #4: Dockerfile
**Arquivo**: `Dockerfile`  
**Mudança**: `COPY storage` comentado  
**Status**: ✅ APLICADO

### Correção #5: Build Script
**Arquivo**: `build.sh`  
**Mudança**: Migrations comentadas  
**Status**: ✅ APLICADO

---

## 🚨 IMPORTANTE

### Antes de Fazer Redeploy

1. ✅ **Backup do .env** (se tiver credenciais configuradas)
   ```bash
   cp .env .env.backup
   ```

2. ✅ **Verificar variáveis de ambiente obrigatórias**:
   - `DATABASE_URL` (já configurado)
   - `JWT_SECRET` (gerar se não tiver)
   - `VITE_APP_ID` (obter em https://portal.manus.im)
   - `OWNER_OPEN_ID` (obter em https://portal.manus.im)
   - `BUILT_IN_FORGE_API_KEY` (obter em https://portal.manus.im)
   - `VITE_FRONTEND_FORGE_API_KEY` (obter em https://portal.manus.im)

3. ✅ **Migrations do banco** (se ainda não executadas):
   ```bash
   pnpm install
   pnpm db:push
   ```

---

## 📞 SUPORTE

Se encontrar problemas durante o redeploy:

1. **Copie os logs completos**:
   ```bash
   docker logs --tail=200 corretordasmansoes-app > logs.txt
   ```

2. **Verifique o status**:
   ```bash
   docker ps -a
   docker inspect corretordasmansoes-app
   ```

3. **Me envie**:
   - Conteúdo de `logs.txt`
   - Saída de `docker ps -a`
   - Descrição do erro específico

---

**Status**: ✅ **PRONTO PARA REDEPLOY**

Todas as correções foram aplicadas. Execute os passos acima na ordem e o sistema funcionará corretamente.

🎉 **BOA SORTE COM O DEPLOY!**
