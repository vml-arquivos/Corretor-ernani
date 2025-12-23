#!/bin/bash

# ============================================
# SCRIPT DE CORREÇÃO DO DRIZZLE SCHEMA
# Corretor das Mansões - Fix Drizzle ORM Error
# ============================================
# 
# Este script corrige o erro crítico:
# "TypeError: propertyTypeEnum.notNull is not a function"
#
# Causa: Sintaxe incorreta do Drizzle ORM para PostgreSQL
# Solução: Adicionar nome da coluna ao chamar o enum
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
echo -e "${CYAN}║     FIX DRIZZLE SCHEMA - CORRETOR DAS MANSÕES         ║${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# VERIFICAR DIRETÓRIO
# ============================================
if [ ! -f "drizzle/schema.ts" ]; then
    echo -e "${RED}❌ ERRO: Arquivo drizzle/schema.ts não encontrado!${NC}"
    echo -e "${YELLOW}Execute este script no diretório raiz do projeto.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Arquivo drizzle/schema.ts encontrado"
echo ""

# ============================================
# BACKUP
# ============================================
echo -e "${BLUE}📦 Criando backup...${NC}"
BACKUP_FILE="drizzle/schema.ts.backup.$(date +%Y%m%d_%H%M%S)"
cp drizzle/schema.ts "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backup criado: ${CYAN}$BACKUP_FILE${NC}"
echo ""

# ============================================
# VERIFICAR SE JÁ FOI CORRIGIDO
# ============================================
echo -e "${BLUE}🔍 Verificando se há erros...${NC}"
ERROR_COUNT=$(grep -c "Enum\.notNull()" drizzle/schema.ts || true)

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Schema já está correto! Nenhuma correção necessária."
    echo ""
    exit 0
fi

echo -e "${YELLOW}⚠${NC}  Encontradas ${RED}$ERROR_COUNT${NC} ocorrências do erro"
echo ""

# ============================================
# APLICAR CORREÇÕES
# ============================================
echo -e "${BLUE}🔧 Aplicando correções...${NC}"

# Correção 1: propertyType
sed -i 's/propertyType: propertyTypeEnum\.notNull()/propertyType: propertyTypeEnum("propertyType").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: propertyType"

# Correção 2: transactionType
sed -i 's/transactionType: transactionTypeEnum\.notNull()/transactionType: transactionTypeEnum("transactionType").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: transactionType"

# Correção 3: type
sed -i 's/type: typeEnum\.notNull()/type: typeEnum("type").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: type (todas as ocorrências)"

# Correção 4: role
sed -i 's/role: roleEnum\.notNull()/role: roleEnum("role").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: role"

# Correção 5: status
sed -i 's/status: statusEnum\.notNull()/status: statusEnum("status").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: status"

# Correção 6: rateType
sed -i 's/rateType: rateTypeEnum\.notNull()/rateType: rateTypeEnum("rateType").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: rateType"

# Correção 7: paymentMethod
sed -i 's/paymentMethod: paymentMethodEnum\.notNull()/paymentMethod: paymentMethodEnum("paymentMethod").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: paymentMethod"

# Correção 8: expenseType
sed -i 's/expenseType: expenseTypeEnum\.notNull()/expenseType: expenseTypeEnum("expenseType").notNull()/g' drizzle/schema.ts
echo -e "${GREEN}✓${NC} Corrigido: expenseType"

echo ""

# ============================================
# VALIDAR CORREÇÕES
# ============================================
echo -e "${BLUE}🔍 Validando correções...${NC}"
REMAINING_ERRORS=$(grep -c "Enum\.notNull()" drizzle/schema.ts || true)

if [ "$REMAINING_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ TODAS AS CORREÇÕES APLICADAS COM SUCESSO!${NC}"
    echo ""
    echo -e "${CYAN}📊 Resumo:${NC}"
    echo -e "  - Erros encontrados: ${RED}$ERROR_COUNT${NC}"
    echo -e "  - Erros corrigidos: ${GREEN}$ERROR_COUNT${NC}"
    echo -e "  - Erros restantes: ${GREEN}0${NC}"
    echo ""
else
    echo -e "${RED}❌ ATENÇÃO: Ainda há $REMAINING_ERRORS erros!${NC}"
    echo -e "${YELLOW}Verifique manualmente o arquivo drizzle/schema.ts${NC}"
    exit 1
fi

# ============================================
# PRÓXIMOS PASSOS
# ============================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              PRÓXIMOS PASSOS                           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}1.${NC} Parar o container atual:"
echo -e "   ${YELLOW}docker-compose down${NC}"
echo ""
echo -e "${BLUE}2.${NC} Fazer rebuild completo:"
echo -e "   ${YELLOW}docker-compose build --no-cache${NC}"
echo ""
echo -e "${BLUE}3.${NC} Iniciar o container:"
echo -e "   ${YELLOW}docker-compose up -d${NC}"
echo ""
echo -e "${BLUE}4.${NC} Verificar logs:"
echo -e "   ${YELLOW}docker logs -f corretordasmansoes-app${NC}"
echo ""
echo -e "${BLUE}5.${NC} Testar acesso:"
echo -e "   ${YELLOW}curl http://localhost:3000/${NC}"
echo ""
echo -e "${GREEN}🎉 CORREÇÃO CONCLUÍDA!${NC}"
echo ""
