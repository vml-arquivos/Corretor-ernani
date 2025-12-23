#!/bin/bash

# ============================================
# SCRIPT DE DIAGNÓSTICO DA VPS
# Corretor das Mansões - Production Diagnostics
# ============================================
# 
# Este script coleta informações detalhadas da VPS
# para diagnóstico e validação do ambiente de produção
#
# Autor: Manus AI - Senior Principal Software Architect
# Data: 2025-12-23
# ============================================

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}║         VPS DIAGNOSTICS - CORRETOR DAS MANSÕES        ║${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

OUTPUT_FILE="vps-diagnostics-$(date +%Y%m%d_%H%M%S).txt"

{
echo "============================================"
echo "VPS DIAGNOSTICS REPORT"
echo "Data: $(date)"
echo "============================================"
echo ""

# ============================================
# 1. INFORMAÇÕES DO SISTEMA
# ============================================
echo "============================================"
echo "1. INFORMAÇÕES DO SISTEMA"
echo "============================================"
echo ""

echo "--- Sistema Operacional ---"
cat /etc/os-release 2>/dev/null || echo "Informação não disponível"
echo ""

echo "--- Kernel ---"
uname -a
echo ""

echo "--- Uptime ---"
uptime
echo ""

echo "--- Memória ---"
free -h
echo ""

echo "--- Disco ---"
df -h
echo ""

echo "--- CPU ---"
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
echo ""

# ============================================
# 2. DOCKER
# ============================================
echo "============================================"
echo "2. DOCKER"
echo "============================================"
echo ""

echo "--- Versão do Docker ---"
docker --version 2>/dev/null || echo "Docker não instalado"
echo ""

echo "--- Versão do Docker Compose ---"
docker-compose --version 2>/dev/null || echo "Docker Compose não instalado"
echo ""

echo "--- Status do Docker ---"
systemctl status docker --no-pager 2>/dev/null || echo "Systemctl não disponível"
echo ""

echo "--- Containers em Execução ---"
docker ps 2>/dev/null || echo "Nenhum container ou Docker não acessível"
echo ""

echo "--- Todos os Containers ---"
docker ps -a 2>/dev/null || echo "Nenhum container ou Docker não acessível"
echo ""

echo "--- Imagens Docker ---"
docker images 2>/dev/null || echo "Nenhuma imagem ou Docker não acessível"
echo ""

echo "--- Uso de Recursos (Docker Stats) ---"
timeout 5 docker stats --no-stream 2>/dev/null || echo "Docker stats não disponível"
echo ""

# ============================================
# 3. APLICAÇÃO CORRETOR DAS MANSÕES
# ============================================
echo "============================================"
echo "3. APLICAÇÃO CORRETOR DAS MANSÕES"
echo "============================================"
echo ""

echo "--- Container da Aplicação ---"
docker ps -a | grep corretor 2>/dev/null || echo "Container não encontrado"
echo ""

echo "--- Logs do Container (últimas 100 linhas) ---"
docker logs --tail=100 corretordasmansoes-app 2>/dev/null || echo "Container não encontrado ou sem logs"
echo ""

echo "--- Inspect do Container ---"
docker inspect corretordasmansoes-app 2>/dev/null || echo "Container não encontrado"
echo ""

echo "--- Estrutura de Diretórios no Container ---"
docker exec corretordasmansoes-app ls -la /app/ 2>/dev/null || echo "Container não acessível"
echo ""

echo "--- Estrutura de dist/ no Container ---"
docker exec corretordasmansoes-app ls -la /app/dist/ 2>/dev/null || echo "Diretório dist não encontrado"
echo ""

echo "--- Estrutura de dist/client/ no Container ---"
docker exec corretordasmansoes-app ls -la /app/dist/client/ 2>/dev/null || echo "Diretório dist/client não encontrado"
echo ""

echo "--- Estrutura de dist/server/ no Container ---"
docker exec corretordasmansoes-app ls -la /app/dist/server/ 2>/dev/null || echo "Diretório dist/server não encontrado"
echo ""

echo "--- Variáveis de Ambiente no Container ---"
docker exec corretordasmansoes-app env 2>/dev/null | grep -E "NODE_ENV|PORT|DATABASE_URL|JWT_SECRET|VITE_APP_ID" || echo "Container não acessível"
echo ""

# ============================================
# 4. REDE E PORTAS
# ============================================
echo "============================================"
echo "4. REDE E PORTAS"
echo "============================================"
echo ""

echo "--- Portas em Uso ---"
netstat -tlnp 2>/dev/null | grep -E "3000|80|443" || ss -tlnp 2>/dev/null | grep -E "3000|80|443" || echo "Nenhuma porta 3000/80/443 em uso"
echo ""

echo "--- Firewall (UFW) ---"
sudo ufw status 2>/dev/null || echo "UFW não instalado ou não configurado"
echo ""

echo "--- IP Externo ---"
curl -s ifconfig.me 2>/dev/null || echo "Não foi possível obter IP externo"
echo ""

# ============================================
# 5. NGINX (se instalado)
# ============================================
echo "============================================"
echo "5. NGINX (se instalado)"
echo "============================================"
echo ""

echo "--- Status do Nginx ---"
systemctl status nginx --no-pager 2>/dev/null || echo "Nginx não instalado"
echo ""

echo "--- Configuração do Nginx ---"
cat /etc/nginx/sites-available/corretordasmansoes 2>/dev/null || echo "Configuração não encontrada"
echo ""

# ============================================
# 6. REPOSITÓRIO GIT
# ============================================
echo "============================================"
echo "6. REPOSITÓRIO GIT"
echo "============================================"
echo ""

echo "--- Branch Atual ---"
git branch --show-current 2>/dev/null || echo "Não é um repositório git"
echo ""

echo "--- Último Commit ---"
git log -1 --oneline 2>/dev/null || echo "Não é um repositório git"
echo ""

echo "--- Status do Git ---"
git status 2>/dev/null || echo "Não é um repositório git"
echo ""

# ============================================
# 7. ARQUIVOS DE CONFIGURAÇÃO
# ============================================
echo "============================================"
echo "7. ARQUIVOS DE CONFIGURAÇÃO"
echo "============================================"
echo ""

echo "--- Arquivo .env (sem valores sensíveis) ---"
if [ -f .env ]; then
    cat .env | grep -E "^[A-Z_]+" | sed 's/=.*/=***HIDDEN***/' 2>/dev/null
else
    echo "Arquivo .env não encontrado"
fi
echo ""

echo "--- docker-compose.yml ---"
cat docker-compose.yml 2>/dev/null || echo "docker-compose.yml não encontrado"
echo ""

echo "--- Dockerfile ---"
cat Dockerfile 2>/dev/null || echo "Dockerfile não encontrado"
echo ""

# ============================================
# 8. TESTES DE CONECTIVIDADE
# ============================================
echo "============================================"
echo "8. TESTES DE CONECTIVIDADE"
echo "============================================"
echo ""

echo "--- Teste HTTP Local (porta 3000) ---"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000/ 2>/dev/null || echo "Não foi possível conectar"
echo ""

echo "--- Teste de Conexão com Supabase ---"
timeout 5 nc -zv db.zeaxqldcytxsbacyqymt.supabase.co 5432 2>&1 || echo "Não foi possível conectar ao Supabase"
echo ""

# ============================================
# 9. PROCESSOS
# ============================================
echo "============================================"
echo "9. PROCESSOS"
echo "============================================"
echo ""

echo "--- Processos Node.js ---"
ps aux | grep node | grep -v grep || echo "Nenhum processo Node.js encontrado"
echo ""

echo "--- Processos Docker ---"
ps aux | grep docker | grep -v grep || echo "Nenhum processo Docker encontrado"
echo ""

# ============================================
# FIM DO RELATÓRIO
# ============================================
echo ""
echo "============================================"
echo "FIM DO RELATÓRIO DE DIAGNÓSTICO"
echo "============================================"

} | tee "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}✅ Relatório salvo em: ${CYAN}$OUTPUT_FILE${NC}"
echo ""
echo -e "${YELLOW}📝 Envie este arquivo para análise:${NC}"
echo -e "   ${CYAN}cat $OUTPUT_FILE${NC}"
echo ""
