#!/bin/bash

# ============================================
# SCRIPT DE CORREÇÃO AUTOMÁTICA
# Corretor das Mansões - Fix Production Issues
# ============================================
# 
# Este script aplica automaticamente todas as correções
# identificadas na análise técnica do sistema.
#
# Autor: Manus AI - Senior Principal Software Architect
# Data: 2025-12-23
# ============================================

set -e  # Exit on error

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}║     CORRETOR DAS MANSÕES - FIX PRODUCTION SCRIPT      ║${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# FUNÇÃO: Verificar se estamos no diretório correto
# ============================================
check_directory() {
    if [ ! -f "package.json" ] || [ ! -f "vite.config.ts" ]; then
        echo -e "${RED}❌ ERRO: Execute este script no diretório raiz do projeto!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Diretório correto verificado"
}

# ============================================
# FUNÇÃO: Backup dos arquivos originais
# ============================================
create_backup() {
    echo ""
    echo -e "${BLUE}📦 Criando backup dos arquivos originais...${NC}"
    
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup dos arquivos que serão modificados
    cp vite.config.ts "$BACKUP_DIR/" 2>/dev/null || true
    cp server/_core/vite.ts "$BACKUP_DIR/" 2>/dev/null || true
    cp Dockerfile "$BACKUP_DIR/" 2>/dev/null || true
    cp build.sh "$BACKUP_DIR/" 2>/dev/null || true
    cp .env "$BACKUP_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}✓${NC} Backup criado em: ${CYAN}$BACKUP_DIR${NC}"
}

# ============================================
# CORREÇÃO #1: Vite Config - Build Path
# ============================================
fix_vite_config() {
    echo ""
    echo -e "${BLUE}🔧 [1/6] Corrigindo vite.config.ts...${NC}"
    
    if grep -q 'dist/public' vite.config.ts; then
        sed -i 's|dist/public|dist/client|g' vite.config.ts
        echo -e "${GREEN}✓${NC} vite.config.ts corrigido (dist/public → dist/client)"
    else
        echo -e "${YELLOW}⚠${NC}  vite.config.ts já estava correto"
    fi
}

# ============================================
# CORREÇÃO #2: Server Vite - Serve Static Path
# ============================================
fix_server_vite() {
    echo ""
    echo -e "${BLUE}🔧 [2/6] Corrigindo server/_core/vite.ts...${NC}"
    
    # Substituir dist/public por dist/client
    if grep -q 'dist.*public' server/_core/vite.ts; then
        sed -i 's|"dist", "public"|"dist", "client"|g' server/_core/vite.ts
        sed -i 's|"public"|"../..", "dist", "client"|g' server/_core/vite.ts
        echo -e "${GREEN}✓${NC} server/_core/vite.ts corrigido"
    else
        echo -e "${YELLOW}⚠${NC}  server/_core/vite.ts já estava correto"
    fi
}

# ============================================
# CORREÇÃO #3: Dockerfile - Remover storage
# ============================================
fix_dockerfile() {
    echo ""
    echo -e "${BLUE}🔧 [3/6] Corrigindo Dockerfile...${NC}"
    
    if grep -q '^COPY storage' Dockerfile; then
        sed -i 's|^COPY storage|# COPY storage|g' Dockerfile
        echo -e "${GREEN}✓${NC} Dockerfile corrigido (COPY storage comentado)"
    else
        echo -e "${YELLOW}⚠${NC}  Dockerfile já estava correto"
    fi
}

# ============================================
# CORREÇÃO #4: Build Script - Remover migrations
# ============================================
fix_build_script() {
    echo ""
    echo -e "${BLUE}🔧 [4/6] Corrigindo build.sh...${NC}"
    
    if grep -q '^pnpm db:push' build.sh; then
        sed -i 's|^pnpm db:push|# pnpm db:push  # Migrations devem ser executadas APÓS deploy|g' build.sh
        echo -e "${GREEN}✓${NC} build.sh corrigido (migrations comentadas)"
    else
        echo -e "${YELLOW}⚠${NC}  build.sh já estava correto"
    fi
}

# ============================================
# CORREÇÃO #5: Variáveis de Ambiente
# ============================================
fix_env_variables() {
    echo ""
    echo -e "${BLUE}🔧 [5/6] Verificando variáveis de ambiente...${NC}"
    
    if [ ! -f .env ]; then
        echo -e "${RED}❌ Arquivo .env não encontrado!${NC}"
        echo -e "${YELLOW}📝 Copiando .env.example para .env...${NC}"
        cp .env.example .env
    fi
    
    # Verificar variáveis críticas
    MISSING_VARS=()
    
    if grep -q "SUBSTITUA_COM_JWT_SECRET_GERADO" .env; then
        MISSING_VARS+=("JWT_SECRET")
    fi
    
    if grep -q "seu_app_id_manus" .env; then
        MISSING_VARS+=("VITE_APP_ID")
    fi
    
    if grep -q "seu_owner_open_id" .env; then
        MISSING_VARS+=("OWNER_OPEN_ID")
    fi
    
    if grep -q "sua_chave_forge_backend" .env; then
        MISSING_VARS+=("BUILT_IN_FORGE_API_KEY")
    fi
    
    if grep -q "sua_chave_forge_frontend" .env; then
        MISSING_VARS+=("VITE_FRONTEND_FORGE_API_KEY")
    fi
    
    if [ ${#MISSING_VARS[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC}  Variáveis de ambiente não configuradas:"
        for var in "${MISSING_VARS[@]}"; do
            echo -e "    - ${RED}$var${NC}"
        done
        echo ""
        echo -e "${CYAN}📝 AÇÃO NECESSÁRIA:${NC}"
        echo -e "   1. Gere JWT_SECRET: ${YELLOW}openssl rand -base64 32${NC}"
        echo -e "   2. Obtenha credenciais Manus em: ${YELLOW}https://portal.manus.im${NC}"
        echo -e "   3. Configure manualmente o arquivo .env"
        echo ""
    else
        echo -e "${GREEN}✓${NC} Variáveis de ambiente configuradas"
    fi
}

# ============================================
# CORREÇÃO #6: Alinhar Schema do Banco
# ============================================
fix_database_schema() {
    echo ""
    echo -e "${BLUE}🔧 [6/6] Preparando script de alinhamento do schema...${NC}"
    
    cat > align-database-schema.sql << 'EOF'
-- ============================================
-- SCRIPT DE ALINHAMENTO DE SCHEMA
-- Corretor das Mansões - PostgreSQL/Supabase
-- ============================================
-- 
-- Este script alinha os ENUMs do banco de dados
-- com o schema do Drizzle ORM
--
-- IMPORTANTE: Execute este script no Supabase
-- após fazer o deploy da aplicação
-- ============================================

-- Atualizar stage_enum
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'stage_enum') THEN
        DROP TYPE stage_enum CASCADE;
    END IF;
END $$;

CREATE TYPE stage_enum AS ENUM (
    'novo',
    'contato_inicial',
    'qualificado',
    'visita_agendada',
    'visita_realizada',
    'proposta',
    'negociacao',
    'fechado_ganho',
    'fechado_perdido',
    'sem_interesse'
);

-- Atualizar source_enum
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'source_enum') THEN
        DROP TYPE source_enum CASCADE;
    END IF;
END $$;

CREATE TYPE source_enum AS ENUM (
    'site',
    'whatsapp',
    'instagram',
    'facebook',
    'indicacao',
    'portal_zap',
    'portal_vivareal',
    'portal_olx',
    'google',
    'outro'
);

-- Atualizar status_enum
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_enum') THEN
        DROP TYPE status_enum CASCADE;
    END IF;
END $$;

CREATE TYPE status_enum AS ENUM (
    'disponivel',
    'reservado',
    'vendido',
    'alugado',
    'inativo'
);

-- Recriar tabelas que usam esses ENUMs
-- (O Drizzle fará isso automaticamente com pnpm db:push)

EOF

    echo -e "${GREEN}✓${NC} Script SQL criado: ${CYAN}align-database-schema.sql${NC}"
    echo -e "${YELLOW}📝 Execute este script no Supabase SQL Editor após o deploy${NC}"
}

# ============================================
# VALIDAÇÃO: Verificar se as correções foram aplicadas
# ============================================
validate_fixes() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              VALIDAÇÃO DAS CORREÇÕES                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    ERRORS=0
    
    # Validar vite.config.ts
    if grep -q 'dist/client' vite.config.ts; then
        echo -e "${GREEN}✓${NC} vite.config.ts: dist/client configurado"
    else
        echo -e "${RED}✗${NC} vite.config.ts: ERRO - dist/client não encontrado"
        ((ERRORS++))
    fi
    
    # Validar server/_core/vite.ts
    if grep -q 'dist.*client' server/_core/vite.ts; then
        echo -e "${GREEN}✓${NC} server/_core/vite.ts: paths corrigidos"
    else
        echo -e "${RED}✗${NC} server/_core/vite.ts: ERRO - paths não corrigidos"
        ((ERRORS++))
    fi
    
    # Validar Dockerfile
    if ! grep -q '^COPY storage' Dockerfile; then
        echo -e "${GREEN}✓${NC} Dockerfile: COPY storage comentado"
    else
        echo -e "${RED}✗${NC} Dockerfile: ERRO - COPY storage ainda ativo"
        ((ERRORS++))
    fi
    
    # Validar build.sh
    if ! grep -q '^pnpm db:push' build.sh; then
        echo -e "${GREEN}✓${NC} build.sh: migrations comentadas"
    else
        echo -e "${RED}✗${NC} build.sh: ERRO - migrations ainda ativas"
        ((ERRORS++))
    fi
    
    echo ""
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✅ TODAS AS CORREÇÕES APLICADAS COM SUCESSO!${NC}"
        return 0
    else
        echo -e "${RED}❌ $ERRORS ERRO(S) ENCONTRADO(S)${NC}"
        return 1
    fi
}

# ============================================
# PRÓXIMOS PASSOS
# ============================================
show_next_steps() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              PRÓXIMOS PASSOS                           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} Configure as variáveis de ambiente no arquivo ${YELLOW}.env${NC}"
    echo ""
    echo -e "   ${CYAN}# Gerar JWT Secret:${NC}"
    echo -e "   ${YELLOW}openssl rand -base64 32${NC}"
    echo ""
    echo -e "   ${CYAN}# Editar .env:${NC}"
    echo -e "   ${YELLOW}nano .env${NC}"
    echo ""
    echo -e "${BLUE}2.${NC} Faça o build do projeto:"
    echo -e "   ${YELLOW}./build.sh${NC}"
    echo ""
    echo -e "${BLUE}3.${NC} Faça o deploy com Docker:"
    echo -e "   ${YELLOW}./deploy.sh${NC}"
    echo ""
    echo -e "${BLUE}4.${NC} Execute as migrations no Supabase:"
    echo -e "   ${YELLOW}pnpm db:push${NC}"
    echo ""
    echo -e "   ${CYAN}OU execute o SQL manualmente:${NC}"
    echo -e "   - Acesse: ${YELLOW}https://supabase.com/dashboard${NC}"
    echo -e "   - Vá em: ${YELLOW}SQL Editor${NC}"
    echo -e "   - Execute: ${YELLOW}align-database-schema.sql${NC}"
    echo ""
    echo -e "${BLUE}5.${NC} Verifique se o sistema está funcionando:"
    echo -e "   ${YELLOW}curl http://localhost:3000/${NC}"
    echo ""
    echo -e "${BLUE}6.${NC} Monitore os logs:"
    echo -e "   ${YELLOW}docker logs -f corretordasmansoes-app${NC}"
    echo ""
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================
main() {
    check_directory
    create_backup
    fix_vite_config
    fix_server_vite
    fix_dockerfile
    fix_build_script
    fix_env_variables
    fix_database_schema
    
    if validate_fixes; then
        show_next_steps
        echo -e "${GREEN}🎉 CORREÇÕES APLICADAS COM SUCESSO!${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}❌ ALGUMAS CORREÇÕES FALHARAM!${NC}"
        echo -e "${YELLOW}Verifique os erros acima e tente novamente.${NC}"
        echo ""
        exit 1
    fi
}

# Executar script
main
