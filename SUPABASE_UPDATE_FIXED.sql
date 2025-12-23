-- ============================================
-- SCRIPT DE ATUALIZAÇÃO CORRIGIDO - TABELAS FALTANTES
-- Sistema: Corretor das Mansões + Agentes de IA N8N
-- ============================================
-- Este script cria APENAS as tabelas que estão faltando
-- Não afeta as tabelas que você já criou
-- VERSÃO CORRIGIDA: Índices criados apenas em colunas existentes
-- ============================================

-- ============================================
-- CRIAR ENUMS FALTANTES
-- ============================================

DO $$ BEGIN
  CREATE TYPE priority_enum AS ENUM ('baixa', 'media', 'alta', 'urgente');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE qualification_enum AS ENUM ('frio', 'morno', 'quente');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE buyer_profile_enum AS ENUM ('investidor', 'primeira_casa', 'upgrade', 'curioso', 'indeciso');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE urgency_level_enum AS ENUM ('baixa', 'media', 'alta', 'imediata');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE transaction_interest_enum AS ENUM ('venda', 'locacao', 'ambos');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE type_enum AS ENUM ('receita', 'despesa');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE client_type_enum AS ENUM ('comprador', 'locatario', 'proprietario');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE rate_type_enum AS ENUM ('sac', 'price');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE payment_method_enum AS ENUM ('boleto', 'pix', 'transferencia', 'dinheiro', 'outro');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE expense_type_enum AS ENUM ('manutencao', 'limpeza', 'reparos', 'seguro', 'iptu', 'condominio', 'agua', 'luz', 'internet', 'outro');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE message_direction_enum AS ENUM ('inbound', 'outbound');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE message_status_enum AS ENUM ('pending', 'sent', 'delivered', 'read', 'failed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE agent_type_enum AS ENUM ('livia', 'analyzer', 'followup', 'scheduler');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ============================================
-- ADICIONAR COLUNAS FALTANTES NA TABELA LEADS
-- ============================================

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS source source_enum DEFAULT 'site';
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS priority priority_enum DEFAULT 'media';
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS qualification qualification_enum DEFAULT 'frio';
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "buyerProfile" buyer_profile_enum;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "urgencyLevel" urgency_level_enum DEFAULT 'media';
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "transactionInterest" transaction_interest_enum;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "budgetMin" DECIMAL(15, 2);
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "budgetMax" DECIMAL(15, 2);
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "preferredLocations" TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS notes TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE leads ADD COLUMN IF NOT EXISTS "lastContactDate" TIMESTAMP;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

-- ============================================
-- ADICIONAR COLUNAS FALTANTES NA TABELA BLOG_POSTS
-- ============================================

DO $$ BEGIN
  ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS excerpt TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS "coverImage" TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS "categoryId" INTEGER;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS "publishedAt" TIMESTAMP;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

-- ============================================
-- ADICIONAR COLUNAS FALTANTES NA TABELA RENTALS
-- ============================================

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "tenantEmail" VARCHAR(320);
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "tenantPhone" VARCHAR(20);
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "tenantCpf" VARCHAR(14);
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "commissionPercentage" DECIMAL(5, 2) DEFAULT 10.00;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "endDate" DATE;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "dueDay" INTEGER;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS notes TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rentals ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

-- ============================================
-- ADICIONAR COLUNAS FALTANTES NA TABELA RENTAL_PAYMENTS
-- ============================================

DO $$ BEGIN
  ALTER TABLE rental_payments ADD COLUMN IF NOT EXISTS "paidDate" DATE;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rental_payments ADD COLUMN IF NOT EXISTS "paymentMethod" payment_method_enum;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rental_payments ADD COLUMN IF NOT EXISTS notes TEXT;
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rental_payments ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE rental_payments ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP DEFAULT NOW();
EXCEPTION
  WHEN duplicate_column THEN null;
  WHEN others THEN null;
END $$;

-- ============================================
-- CRIAR TABELAS FALTANTES
-- ============================================

-- 1. TABELA DE IMAGENS DE IMÓVEIS
CREATE TABLE IF NOT EXISTS property_images (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  "altText" VARCHAR(255),
  "displayOrder" INTEGER DEFAULT 0,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_property_images_property ON property_images("propertyId");

-- 2. TABELA DE INTERAÇÕES
CREATE TABLE IF NOT EXISTS interactions (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  description TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_interactions_lead ON interactions("leadId");
CREATE INDEX IF NOT EXISTS idx_interactions_type ON interactions(type);

-- 3. TABELA DE CATEGORIAS DO BLOG
CREATE TABLE IF NOT EXISTS blog_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blog_categories_slug ON blog_categories(slug);

-- 4. TABELA DE CONFIGURAÇÕES DO SITE
CREATE TABLE IF NOT EXISTS site_settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(100) NOT NULL UNIQUE,
  value TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_settings_key ON site_settings(key);

-- 5. TABELA DE PROPRIETÁRIOS
CREATE TABLE IF NOT EXISTS owners (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(320),
  phone VARCHAR(20),
  cpf VARCHAR(14),
  cnpj VARCHAR(18),
  address TEXT,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Criar índices apenas se a tabela foi criada com sucesso
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'owners' AND column_name = 'email') THEN
    CREATE INDEX IF NOT EXISTS idx_owners_email ON owners(email);
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'owners' AND column_name = 'cpf') THEN
    CREATE INDEX IF NOT EXISTS idx_owners_cpf ON owners(cpf);
  END IF;
END $$;

-- 6. TABELA DE ANALYTICS
CREATE TABLE IF NOT EXISTS analytics_events (
  id SERIAL PRIMARY KEY,
  event VARCHAR(100) NOT NULL,
  data JSONB,
  "userId" INTEGER REFERENCES users(id) ON DELETE SET NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE SET NULL,
  "sessionId" VARCHAR(100),
  "ipAddress" VARCHAR(45),
  "userAgent" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_event ON analytics_events(event);
CREATE INDEX IF NOT EXISTS idx_analytics_created ON analytics_events("createdAt");

-- 7. TABELA DE FONTES DE CAMPANHA
CREATE TABLE IF NOT EXISTS campaign_sources (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  utm_source VARCHAR(100),
  utm_medium VARCHAR(100),
  utm_campaign VARCHAR(100),
  "leadCount" INTEGER DEFAULT 0,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 8. TABELA DE TRANSAÇÕES FINANCEIRAS
CREATE TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  type type_enum NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  description TEXT,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE SET NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);

-- 9. TABELA DE COMISSÕES
CREATE TABLE IF NOT EXISTS commissions (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE CASCADE,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE CASCADE,
  amount DECIMAL(15, 2) NOT NULL,
  percentage DECIMAL(5, 2),
  status status_enum NOT NULL DEFAULT 'pendente',
  "paidAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_commissions_status ON commissions(status);

-- 10. TABELA DE AVALIAÇÕES
CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE CASCADE,
  "clientName" VARCHAR(255) NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  approved BOOLEAN DEFAULT FALSE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_property ON reviews("propertyId");
CREATE INDEX IF NOT EXISTS idx_reviews_approved ON reviews(approved);

-- 11. TABELA DE TAXAS DE JUROS (SIMULADOR)
CREATE TABLE IF NOT EXISTS interest_rates (
  id SERIAL PRIMARY KEY,
  bank VARCHAR(100) NOT NULL,
  "rateType" rate_type_enum NOT NULL,
  "annualRate" DECIMAL(5, 4) NOT NULL,
  "monthlyRate" DECIMAL(5, 4) NOT NULL,
  "minAmount" DECIMAL(15, 2),
  "maxAmount" DECIMAL(15, 2),
  "minTerm" INTEGER,
  "maxTerm" INTEGER,
  "validFrom" DATE NOT NULL,
  "validUntil" DATE,
  active BOOLEAN DEFAULT TRUE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_interest_rates_bank ON interest_rates(bank);
CREATE INDEX IF NOT EXISTS idx_interest_rates_active ON interest_rates(active);

-- 12. TABELA DE DESPESAS DE ALUGUEL
CREATE TABLE IF NOT EXISTS rental_expenses (
  id SERIAL PRIMARY KEY,
  "rentalId" INTEGER NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
  "expenseType" expense_type_enum NOT NULL,
  description TEXT,
  amount DECIMAL(10, 2) NOT NULL,
  "expenseDate" DATE NOT NULL,
  "paidBy" client_type_enum NOT NULL,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rental_expenses_rental ON rental_expenses("rentalId");

-- 13. TABELA DE CONTRATOS DE ALUGUEL
CREATE TABLE IF NOT EXISTS rental_contracts (
  id SERIAL PRIMARY KEY,
  "rentalId" INTEGER NOT NULL UNIQUE REFERENCES rentals(id) ON DELETE CASCADE,
  "contractUrl" TEXT,
  "signedDate" DATE,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================
-- TABELAS PARA AGENTES DE IA E N8N
-- ============================================

-- 14. TABELA DE SESSÕES DE CONVERSA
CREATE TABLE IF NOT EXISTS conversation_sessions (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "sessionId" VARCHAR(100) NOT NULL UNIQUE,
  "phoneNumber" VARCHAR(20),
  "startedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "lastMessageAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "endedAt" TIMESTAMP,
  active BOOLEAN DEFAULT TRUE,
  metadata JSONB
);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_lead ON conversation_sessions("leadId");
CREATE INDEX IF NOT EXISTS idx_conversation_sessions_session ON conversation_sessions("sessionId");
CREATE INDEX IF NOT EXISTS idx_conversation_sessions_phone ON conversation_sessions("phoneNumber");

-- 15. TABELA DE HISTÓRICO DE CHAT
CREATE TABLE IF NOT EXISTS chat_history (
  id SERIAL PRIMARY KEY,
  "sessionId" VARCHAR(100) NOT NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  direction message_direction_enum NOT NULL,
  content TEXT NOT NULL,
  "messageType" VARCHAR(50) DEFAULT 'text',
  "mediaUrl" TEXT,
  "sentAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "deliveredAt" TIMESTAMP,
  "readAt" TIMESTAMP,
  status message_status_enum DEFAULT 'pending',
  metadata JSONB
);

CREATE INDEX IF NOT EXISTS idx_chat_history_session ON chat_history("sessionId");
CREATE INDEX IF NOT EXISTS idx_chat_history_lead ON chat_history("leadId");
CREATE INDEX IF NOT EXISTS idx_chat_history_sent ON chat_history("sentAt");

-- 16. TABELA DE BUFFER DE MENSAGENS (FILA)
CREATE TABLE IF NOT EXISTS message_buffer (
  id SERIAL PRIMARY KEY,
  "sessionId" VARCHAR(100) NOT NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "phoneNumber" VARCHAR(20) NOT NULL,
  content TEXT NOT NULL,
  "messageType" VARCHAR(50) DEFAULT 'text',
  "mediaUrl" TEXT,
  "scheduledFor" TIMESTAMP,
  "processedAt" TIMESTAMP,
  status message_status_enum DEFAULT 'pending',
  "retryCount" INTEGER DEFAULT 0,
  "lastError" TEXT,
  metadata JSONB,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_message_buffer_session ON message_buffer("sessionId");
CREATE INDEX IF NOT EXISTS idx_message_buffer_status ON message_buffer(status);
CREATE INDEX IF NOT EXISTS idx_message_buffer_scheduled ON message_buffer("scheduledFor");

-- 17. TABELA DE STATUS DE CONTEXTO DE IA
CREATE TABLE IF NOT EXISTS ai_context_status (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL UNIQUE REFERENCES leads(id) ON DELETE CASCADE,
  "sessionId" VARCHAR(100),
  "currentIntent" VARCHAR(100),
  "lastInteraction" TIMESTAMP,
  "conversationStage" VARCHAR(50),
  "extractedData" JSONB,
  "pendingActions" JSONB,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_context_lead ON ai_context_status("leadId");

-- 18. TABELA DE INTERESSES DO CLIENTE
CREATE TABLE IF NOT EXISTS client_interests (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  "propertyType" property_type_enum,
  "transactionType" transaction_type_enum,
  "budgetMin" DECIMAL(15, 2),
  "budgetMax" DECIMAL(15, 2),
  "preferredLocations" TEXT,
  bedrooms INTEGER,
  bathrooms INTEGER,
  "parkingSpaces" INTEGER,
  "minArea" DECIMAL(10, 2),
  "maxArea" DECIMAL(10, 2),
  notes TEXT,
  "extractedFrom" VARCHAR(50),
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_interests_lead ON client_interests("leadId");

-- 19. TABELA DE LOGS DE WEBHOOK
CREATE TABLE IF NOT EXISTS webhook_logs (
  id SERIAL PRIMARY KEY,
  "webhookType" VARCHAR(100) NOT NULL,
  "requestMethod" VARCHAR(10),
  "requestUrl" TEXT,
  "requestHeaders" JSONB,
  "requestBody" JSONB,
  "responseStatus" INTEGER,
  "responseBody" JSONB,
  "processedAt" TIMESTAMP,
  success BOOLEAN,
  "errorMessage" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_webhook_logs_type ON webhook_logs("webhookType");
CREATE INDEX IF NOT EXISTS idx_webhook_logs_success ON webhook_logs(success);

-- 20. TABELA DE LOGS DE AGENTES DE IA
CREATE TABLE IF NOT EXISTS ai_agent_logs (
  id SERIAL PRIMARY KEY,
  "agentType" agent_type_enum NOT NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "sessionId" VARCHAR(100),
  action VARCHAR(100) NOT NULL,
  input JSONB,
  output JSONB,
  "executionTime" INTEGER,
  success BOOLEAN,
  "errorMessage" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_agent_logs_agent ON ai_agent_logs("agentType");
CREATE INDEX IF NOT EXISTS idx_ai_agent_logs_lead ON ai_agent_logs("leadId");

-- ============================================
-- ADICIONAR CHAVES ESTRANGEIRAS FALTANTES
-- ============================================

DO $$ BEGIN
  ALTER TABLE blog_posts ADD CONSTRAINT fk_blog_posts_category FOREIGN KEY ("categoryId") REFERENCES blog_categories(id) ON DELETE SET NULL;
EXCEPTION
  WHEN duplicate_object THEN null;
  WHEN others THEN null;
END $$;

-- ============================================
-- INSERIR DADOS INICIAIS
-- ============================================

-- Configurações do site
INSERT INTO site_settings (key, value) VALUES
  ('site_name', 'Corretor das Mansões - Ernani Nunes'),
  ('site_email', 'ernanisimiao@hotmail.com'),
  ('site_phone', '(61) 98129-9575'),
  ('whatsapp_number', '5561981299575'),
  ('address', 'Brasília, DF'),
  ('instagram_url', 'https://instagram.com/corretordasmansoes'),
  ('enable_chat', 'true'),
  ('enable_n8n', 'true'),
  ('ai_agent_enabled', 'true')
ON CONFLICT (key) DO NOTHING;

-- Categorias de blog
INSERT INTO blog_categories (name, slug, description) VALUES
  ('Mercado Imobiliário', 'mercado-imobiliario', 'Notícias e análises do mercado'),
  ('Dicas para Compradores', 'dicas-compradores', 'Orientações para compradores'),
  ('Financiamento', 'financiamento', 'Informações sobre financiamento')
ON CONFLICT (slug) DO NOTHING;

-- Taxas de juros
INSERT INTO interest_rates (bank, "rateType", "annualRate", "monthlyRate", "validFrom", active) VALUES
  ('Caixa Econômica Federal', 'sac', 0.0899, 0.0072, CURRENT_DATE, true),
  ('Caixa Econômica Federal', 'price', 0.0949, 0.0076, CURRENT_DATE, true),
  ('Banco do Brasil', 'sac', 0.0879, 0.0070, CURRENT_DATE, true),
  ('Banco do Brasil', 'price', 0.0929, 0.0074, CURRENT_DATE, true),
  ('Bradesco', 'sac', 0.0919, 0.0074, CURRENT_DATE, true),
  ('Bradesco', 'price', 0.0969, 0.0078, CURRENT_DATE, true),
  ('Itaú', 'sac', 0.0909, 0.0073, CURRENT_DATE, true),
  ('Itaú', 'price', 0.0959, 0.0077, CURRENT_DATE, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================
-- FIM DO SCRIPT DE ATUALIZAÇÃO CORRIGIDO
-- ============================================
