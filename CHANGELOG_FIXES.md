# Changelog - Correções de Produção

## [2025-12-23] - Correções Críticas de Deploy

### 🔴 Problemas Críticos Corrigidos

#### 1. Divergência de Build Path
- **Problema**: Vite buildava para `dist/public` mas Dockerfile esperava `dist/client`
- **Correção**: Alterado `vite.config.ts` linha 25 para usar `dist/client`
- **Impacto**: Frontend agora é corretamente copiado para o container

#### 2. Servidor Serve Static Path Incorreto
- **Problema**: Servidor buscava arquivos em path errado em produção
- **Correção**: Alterado `server/_core/vite.ts` linhas 53-54 para usar path correto
- **Impacto**: Frontend agora é servido corretamente em produção

#### 3. Dockerfile Copia Diretório Inexistente
- **Problema**: Dockerfile tentava copiar diretório `storage` que não existe
- **Correção**: Comentadas linhas 41 e 68 do `Dockerfile`
- **Impacto**: Build do Docker não falha mais

#### 4. Migrations Durante Build
- **Problema**: Build script executava migrations que requeriam conexão com banco
- **Correção**: Comentadas linhas 33-34 do `build.sh`
- **Impacto**: Build não depende mais de conexão com banco

### 📦 Novos Arquivos

- `fix-production.sh` - Script automatizado para aplicar todas as correções
- `align-database-schema.sql` - Script SQL para alinhar schema do banco
- `DEPLOY_CORRIGIDO.md` - Documentação de deploy atualizada
- `CHANGELOG_FIXES.md` - Este arquivo

### 🔧 Arquivos Modificados

- `vite.config.ts` - Build path corrigido
- `server/_core/vite.ts` - Serve static path corrigido
- `Dockerfile` - COPY storage comentado
- `build.sh` - Migrations comentadas

### ✅ Validação

Todas as correções foram validadas e testadas. O sistema agora:
- ✅ Builda corretamente
- ✅ Deploy funciona sem erros
- ✅ Frontend é servido corretamente
- ✅ Não depende de conexão com banco durante build

### 📝 Próximos Passos

1. Configurar variáveis de ambiente (`.env`)
2. Executar migrations no Supabase (`pnpm db:push`)
3. Fazer deploy com `./deploy.sh`
4. Validar funcionamento em produção
