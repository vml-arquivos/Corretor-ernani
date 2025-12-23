-- ============================================
-- SCRIPT SQL COMPLETO PARA SUPABASE
-- Sistema: Corretor das Mansões + Agentes de IA N8N
-- Banco: PostgreSQL 16
-- ============================================
-- INSTRUÇÕES:
-- 1. Acesse: https://supabase.com/dashboard/project/zeaxqldcytxsbacyqymt
-- 2. Vá em "SQL Editor"
-- 3. Clique em "New query"
-- 4. Cole TODO este script
-- 5. Clique em "Run"
-- ============================================

-- Limpar tabelas existentes (CUIDADO: use apenas na primeira vez)
DROP TABLE IF EXISTS rental_contracts CASCADE;
DROP TABLE IF EXISTS rental_expenses CASCADE;
DROP TABLE IF EXISTS rental_payments CASCADE;
DROP TABLE IF EXISTS rentals CASCADE;
DROP TABLE IF EXISTS interest_rates CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS commissions CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS campaign_sources CASCADE;
DROP TABLE IF EXISTS analytics_events CASCADE;
DROP TABLE IF EXISTS owners CASCADE;
DROP TABLE IF EXISTS webhook_logs CASCADE;
DROP TABLE IF EXISTS client_interests CASCADE;
DROP TABLE IF EXISTS ai_context_status CASCADE;
DROP TABLE IF EXISTS message_buffer CASCADE;
DROP TABLE IF EXISTS chat_history CASCADE;
DROP TABLE IF EXISTS conversation_sessions CASCADE;
DROP TABLE IF EXISTS ai_agent_logs CASCADE;
DROP TABLE IF EXISTS site_settings CASCADE;
DROP TABLE IF EXISTS blog_categories CASCADE;
DROP TABLE IF EXISTS blog_posts CASCADE;
DROP TABLE IF EXISTS interactions CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS role_enum CASCADE;
DROP TYPE IF EXISTS property_type_enum CASCADE;
DROP TYPE IF EXISTS transaction_type_enum CASCADE;
DROP TYPE IF EXISTS stage_enum CASCADE;
DROP TYPE IF EXISTS source_enum CASCADE;
DROP TYPE IF EXISTS priority_enum CASCADE;
DROP TYPE IF EXISTS qualification_enum CASCADE;
DROP TYPE IF EXISTS buyer_profile_enum CASCADE;
DROP TYPE IF EXISTS urgency_level_enum CASCADE;
DROP TYPE IF EXISTS transaction_interest_enum CASCADE;
DROP TYPE IF EXISTS status_enum CASCADE;
DROP TYPE IF EXISTS type_enum CASCADE;
DROP TYPE IF EXISTS client_type_enum CASCADE;
DROP TYPE IF EXISTS rate_type_enum CASCADE;
DROP TYPE IF EXISTS interest_type_enum CASCADE;
DROP TYPE IF EXISTS payment_method_enum CASCADE;
DROP TYPE IF EXISTS expense_type_enum CASCADE;
DROP TYPE IF EXISTS message_direction_enum CASCADE;
DROP TYPE IF EXISTS message_status_enum CASCADE;
DROP TYPE IF EXISTS agent_type_enum CASCADE;

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE role_enum AS ENUM ('user', 'admin');
CREATE TYPE property_type_enum AS ENUM ('casa', 'apartamento', 'cobertura', 'terreno', 'comercial', 'rural', 'lancamento');
CREATE TYPE transaction_type_enum AS ENUM ('venda', 'locacao', 'ambos');
CREATE TYPE stage_enum AS ENUM ('novo', 'contato', 'qualificado', 'visita', 'proposta', 'negociacao', 'fechado', 'perdido');
CREATE TYPE source_enum AS ENUM ('site', 'whatsapp', 'telefone', 'email', 'indicacao', 'redes_sociais', 'outro');
CREATE TYPE priority_enum AS ENUM ('baixa', 'media', 'alta', 'urgente');
CREATE TYPE qualification_enum AS ENUM ('frio', 'morno', 'quente');
CREATE TYPE buyer_profile_enum AS ENUM ('investidor', 'primeira_casa', 'upgrade', 'curioso', 'indeciso');
CREATE TYPE urgency_level_enum AS ENUM ('baixa', 'media', 'alta', 'imediata');
CREATE TYPE transaction_interest_enum AS ENUM ('venda', 'locacao', 'ambos');
CREATE TYPE status_enum AS ENUM ('ativo', 'inativo', 'pendente');
CREATE TYPE type_enum AS ENUM ('receita', 'despesa');
CREATE TYPE client_type_enum AS ENUM ('comprador', 'locatario', 'proprietario');
CREATE TYPE rate_type_enum AS ENUM ('sac', 'price');
CREATE TYPE interest_type_enum AS ENUM ('venda', 'locacao', 'ambos');
CREATE TYPE payment_method_enum AS ENUM ('boleto', 'pix', 'transferencia', 'dinheiro', 'outro');
CREATE TYPE expense_type_enum AS ENUM ('manutencao', 'limpeza', 'reparos', 'seguro', 'iptu', 'condominio', 'agua', 'luz', 'internet', 'outro');
CREATE TYPE message_direction_enum AS ENUM ('inbound', 'outbound');
CREATE TYPE message_status_enum AS ENUM ('pending', 'sent', 'delivered', 'read', 'failed');
CREATE TYPE agent_type_enum AS ENUM ('livia', 'analyzer', 'followup', 'scheduler');

-- ============================================
-- TABELA DE USUÁRIOS (AUTH)
-- ============================================

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  "openId" VARCHAR(64) NOT NULL UNIQUE,
  name TEXT,
  email VARCHAR(320),
  "loginMethod" VARCHAR(64),
  role role_enum NOT NULL DEFAULT 'user',
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "lastSignedIn" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_openid ON users("openId");
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- TABELA DE IMÓVEIS
-- ============================================

CREATE TABLE properties (
  id SERIAL PRIMARY KEY,
  
  -- Informações básicas
  title VARCHAR(255) NOT NULL,
  description TEXT,
  "referenceCode" VARCHAR(50) UNIQUE,
  
  -- Tipo e finalidade
  "propertyType" property_type_enum NOT NULL,
  "transactionType" transaction_type_enum NOT NULL,
  
  -- Localização
  address TEXT,
  neighborhood VARCHAR(100),
  city VARCHAR(100),
  state VARCHAR(2),
  "zipCode" VARCHAR(10),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  
  -- Características
  bedrooms INTEGER,
  bathrooms INTEGER,
  "parkingSpaces" INTEGER,
  area DECIMAL(10, 2),
  "builtArea" DECIMAL(10, 2),
  
  -- Valores
  price DECIMAL(15, 2),
  "rentalPrice" DECIMAL(15, 2),
  "condoFee" DECIMAL(10, 2),
  "iptuValue" DECIMAL(10, 2),
  
  -- Imagens e mídia
  "mainImage" TEXT,
  images JSONB,
  "videoUrl" TEXT,
  "virtualTourUrl" TEXT,
  
  -- Status e destaque
  status status_enum NOT NULL DEFAULT 'ativo',
  featured BOOLEAN DEFAULT FALSE,
  
  -- Relacionamento com proprietário
  "ownerId" INTEGER,
  
  -- Metadados
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_properties_type ON properties("propertyType");
CREATE INDEX idx_properties_transaction ON properties("transactionType");
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_featured ON properties(featured);
CREATE INDEX idx_properties_owner ON properties("ownerId");
CREATE INDEX idx_properties_price ON properties(price);

-- ============================================
-- TABELA DE IMAGENS DE IMÓVEIS
-- ============================================

CREATE TABLE property_images (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER NOT NULL,
  url TEXT NOT NULL,
  "altText" VARCHAR(255),
  "displayOrder" INTEGER DEFAULT 0,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_property_images_property ON property_images("propertyId");

-- ============================================
-- TABELA DE LEADS
-- ============================================

CREATE TABLE leads (
  id SERIAL PRIMARY KEY,
  
  -- Informações pessoais
  name VARCHAR(255) NOT NULL,
  email VARCHAR(320),
  phone VARCHAR(20),
  
  -- Perfil e qualificação
  stage stage_enum NOT NULL DEFAULT 'novo',
  source source_enum NOT NULL DEFAULT 'site',
  priority priority_enum DEFAULT 'media',
  qualification qualification_enum DEFAULT 'frio',
  "buyerProfile" buyer_profile_enum,
  "urgencyLevel" urgency_level_enum DEFAULT 'media',
  
  -- Interesse
  "transactionInterest" transaction_interest_enum,
  "interestedPropertyId" INTEGER,
  "budgetMin" DECIMAL(15, 2),
  "budgetMax" DECIMAL(15, 2),
  "preferredLocations" TEXT,
  
  -- Notas e observações
  notes TEXT,
  
  -- Metadados
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "lastContactDate" TIMESTAMP
);

CREATE INDEX idx_leads_stage ON leads(stage);
CREATE INDEX idx_leads_source ON leads(source);
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_phone ON leads(phone);
CREATE INDEX idx_leads_property ON leads("interestedPropertyId");
CREATE INDEX idx_leads_qualification ON leads(qualification);

-- ============================================
-- TABELA DE INTERAÇÕES
-- ============================================

CREATE TABLE interactions (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL,
  type VARCHAR(50) NOT NULL,
  description TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_interactions_lead ON interactions("leadId");
CREATE INDEX idx_interactions_type ON interactions(type);
CREATE INDEX idx_interactions_created ON interactions("createdAt");

-- ============================================
-- TABELA DE BLOG
-- ============================================

CREATE TABLE blog_posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  content TEXT NOT NULL,
  excerpt TEXT,
  "coverImage" TEXT,
  "authorId" INTEGER,
  "categoryId" INTEGER,
  published BOOLEAN DEFAULT FALSE,
  "publishedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_blog_slug ON blog_posts(slug);
CREATE INDEX idx_blog_published ON blog_posts(published);
CREATE INDEX idx_blog_author ON blog_posts("authorId");
CREATE INDEX idx_blog_category ON blog_posts("categoryId");

-- ============================================
-- TABELA DE CATEGORIAS DO BLOG
-- ============================================

CREATE TABLE blog_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_blog_categories_slug ON blog_categories(slug);

-- ============================================
-- TABELA DE CONFIGURAÇÕES DO SITE
-- ============================================

CREATE TABLE site_settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(100) NOT NULL UNIQUE,
  value TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_site_settings_key ON site_settings(key);

-- ============================================
-- TABELA DE PROPRIETÁRIOS
-- ============================================

CREATE TABLE owners (
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

CREATE INDEX idx_owners_email ON owners(email);
CREATE INDEX idx_owners_cpf ON owners(cpf);
CREATE INDEX idx_owners_cnpj ON owners(cnpj);

-- ============================================
-- TABELA DE ANALYTICS
-- ============================================

CREATE TABLE analytics_events (
  id SERIAL PRIMARY KEY,
  event VARCHAR(100) NOT NULL,
  data JSONB,
  "userId" INTEGER,
  "leadId" INTEGER,
  "propertyId" INTEGER,
  "sessionId" VARCHAR(100),
  "ipAddress" VARCHAR(45),
  "userAgent" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_analytics_event ON analytics_events(event);
CREATE INDEX idx_analytics_user ON analytics_events("userId");
CREATE INDEX idx_analytics_lead ON analytics_events("leadId");
CREATE INDEX idx_analytics_property ON analytics_events("propertyId");
CREATE INDEX idx_analytics_session ON analytics_events("sessionId");
CREATE INDEX idx_analytics_created ON analytics_events("createdAt");

-- ============================================
-- TABELA DE FONTES DE CAMPANHA
-- ============================================

CREATE TABLE campaign_sources (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  utm_source VARCHAR(100),
  utm_medium VARCHAR(100),
  utm_campaign VARCHAR(100),
  utm_term VARCHAR(100),
  utm_content VARCHAR(100),
  "leadCount" INTEGER DEFAULT 0,
  "conversionRate" DECIMAL(5, 2),
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_campaign_sources_name ON campaign_sources(name);
CREATE INDEX idx_campaign_sources_utm ON campaign_sources(utm_source, utm_medium, utm_campaign);

-- ============================================
-- TABELA DE TRANSAÇÕES FINANCEIRAS
-- ============================================

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  type type_enum NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  description TEXT,
  "propertyId" INTEGER,
  "leadId" INTEGER,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_property ON transactions("propertyId");
CREATE INDEX idx_transactions_lead ON transactions("leadId");
CREATE INDEX idx_transactions_created ON transactions("createdAt");

-- ============================================
-- TABELA DE COMISSÕES
-- ============================================

CREATE TABLE commissions (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER,
  "leadId" INTEGER,
  amount DECIMAL(15, 2) NOT NULL,
  percentage DECIMAL(5, 2),
  status status_enum NOT NULL DEFAULT 'pendente',
  "paidAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_commissions_property ON commissions("propertyId");
CREATE INDEX idx_commissions_lead ON commissions("leadId");
CREATE INDEX idx_commissions_status ON commissions(status);

-- ============================================
-- TABELA DE AVALIAÇÕES
-- ============================================

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER,
  "clientName" VARCHAR(255) NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  approved BOOLEAN DEFAULT FALSE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reviews_property ON reviews("propertyId");
CREATE INDEX idx_reviews_approved ON reviews(approved);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- ============================================
-- TABELA DE TAXAS DE JUROS (SIMULADOR)
-- ============================================

CREATE TABLE interest_rates (
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

CREATE INDEX idx_interest_rates_bank ON interest_rates(bank);
CREATE INDEX idx_interest_rates_type ON interest_rates("rateType");
CREATE INDEX idx_interest_rates_active ON interest_rates(active);

-- ============================================
-- TABELA DE ALUGUÉIS
-- ============================================

CREATE TABLE rentals (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER NOT NULL,
  "tenantName" VARCHAR(255) NOT NULL,
  "tenantEmail" VARCHAR(320),
  "tenantPhone" VARCHAR(20),
  "tenantCpf" VARCHAR(14),
  "rentalAmount" DECIMAL(10, 2) NOT NULL,
  "commissionPercentage" DECIMAL(5, 2) DEFAULT 10.00,
  "startDate" DATE NOT NULL,
  "endDate" DATE,
  "dueDay" INTEGER NOT NULL CHECK ("dueDay" >= 1 AND "dueDay" <= 31),
  status status_enum NOT NULL DEFAULT 'ativo',
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rentals_property ON rentals("propertyId");
CREATE INDEX idx_rentals_status ON rentals(status);
CREATE INDEX idx_rentals_tenant_email ON rentals("tenantEmail");

-- ============================================
-- TABELA DE PAGAMENTOS DE ALUGUEL
-- ============================================

CREATE TABLE rental_payments (
  id SERIAL PRIMARY KEY,
  "rentalId" INTEGER NOT NULL,
  "dueDate" DATE NOT NULL,
  "paidDate" DATE,
  amount DECIMAL(10, 2) NOT NULL,
  "paymentMethod" payment_method_enum,
  status status_enum NOT NULL DEFAULT 'pendente',
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_payments_rental ON rental_payments("rentalId");
CREATE INDEX idx_rental_payments_status ON rental_payments(status);
CREATE INDEX idx_rental_payments_due_date ON rental_payments("dueDate");

-- ============================================
-- TABELA DE DESPESAS DE ALUGUEL
-- ============================================

CREATE TABLE rental_expenses (
  id SERIAL PRIMARY KEY,
  "rentalId" INTEGER NOT NULL,
  "expenseType" expense_type_enum NOT NULL,
  description TEXT,
  amount DECIMAL(10, 2) NOT NULL,
  "expenseDate" DATE NOT NULL,
  "paidBy" client_type_enum NOT NULL,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_expenses_rental ON rental_expenses("rentalId");
CREATE INDEX idx_rental_expenses_type ON rental_expenses("expenseType");
CREATE INDEX idx_rental_expenses_date ON rental_expenses("expenseDate");

-- ============================================
-- TABELA DE CONTRATOS DE ALUGUEL
-- ============================================

CREATE TABLE rental_contracts (
  id SERIAL PRIMARY KEY,
  "rentalId" INTEGER NOT NULL UNIQUE,
  "contractUrl" TEXT,
  "signedDate" DATE,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_contracts_rental ON rental_contracts("rentalId");

-- ============================================
-- TABELAS PARA AGENTES DE IA E N8N
-- ============================================

-- ============================================
-- TABELA DE SESSÕES DE CONVERSA
-- ============================================

CREATE TABLE conversation_sessions (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER,
  "sessionId" VARCHAR(100) NOT NULL UNIQUE,
  "phoneNumber" VARCHAR(20),
  "startedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "lastMessageAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "endedAt" TIMESTAMP,
  active BOOLEAN DEFAULT TRUE,
  metadata JSONB
);

CREATE INDEX idx_conversation_sessions_lead ON conversation_sessions("leadId");
CREATE INDEX idx_conversation_sessions_session ON conversation_sessions("sessionId");
CREATE INDEX idx_conversation_sessions_phone ON conversation_sessions("phoneNumber");
CREATE INDEX idx_conversation_sessions_active ON conversation_sessions(active);

-- ============================================
-- TABELA DE HISTÓRICO DE CHAT
-- ============================================

CREATE TABLE chat_history (
  id SERIAL PRIMARY KEY,
  "sessionId" VARCHAR(100) NOT NULL,
  "leadId" INTEGER,
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

CREATE INDEX idx_chat_history_session ON chat_history("sessionId");
CREATE INDEX idx_chat_history_lead ON chat_history("leadId");
CREATE INDEX idx_chat_history_direction ON chat_history(direction);
CREATE INDEX idx_chat_history_sent ON chat_history("sentAt");

-- ============================================
-- TABELA DE BUFFER DE MENSAGENS (FILA)
-- ============================================

CREATE TABLE message_buffer (
  id SERIAL PRIMARY KEY,
  "sessionId" VARCHAR(100) NOT NULL,
  "leadId" INTEGER,
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

CREATE INDEX idx_message_buffer_session ON message_buffer("sessionId");
CREATE INDEX idx_message_buffer_lead ON message_buffer("leadId");
CREATE INDEX idx_message_buffer_phone ON message_buffer("phoneNumber");
CREATE INDEX idx_message_buffer_status ON message_buffer(status);
CREATE INDEX idx_message_buffer_scheduled ON message_buffer("scheduledFor");

-- ============================================
-- TABELA DE STATUS DE CONTEXTO DE IA
-- ============================================

CREATE TABLE ai_context_status (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL UNIQUE,
  "sessionId" VARCHAR(100),
  "currentIntent" VARCHAR(100),
  "lastInteraction" TIMESTAMP,
  "conversationStage" VARCHAR(50),
  "extractedData" JSONB,
  "pendingActions" JSONB,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_context_lead ON ai_context_status("leadId");
CREATE INDEX idx_ai_context_session ON ai_context_status("sessionId");
CREATE INDEX idx_ai_context_intent ON ai_context_status("currentIntent");

-- ============================================
-- TABELA DE INTERESSES DO CLIENTE
-- ============================================

CREATE TABLE client_interests (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL,
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

CREATE INDEX idx_client_interests_lead ON client_interests("leadId");
CREATE INDEX idx_client_interests_property_type ON client_interests("propertyType");
CREATE INDEX idx_client_interests_transaction ON client_interests("transactionType");

-- ============================================
-- TABELA DE LOGS DE WEBHOOK
-- ============================================

CREATE TABLE webhook_logs (
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

CREATE INDEX idx_webhook_logs_type ON webhook_logs("webhookType");
CREATE INDEX idx_webhook_logs_success ON webhook_logs(success);
CREATE INDEX idx_webhook_logs_created ON webhook_logs("createdAt");

-- ============================================
-- TABELA DE LOGS DE AGENTES DE IA
-- ============================================

CREATE TABLE ai_agent_logs (
  id SERIAL PRIMARY KEY,
  "agentType" agent_type_enum NOT NULL,
  "leadId" INTEGER,
  "sessionId" VARCHAR(100),
  action VARCHAR(100) NOT NULL,
  input JSONB,
  output JSONB,
  "executionTime" INTEGER,
  success BOOLEAN,
  "errorMessage" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_agent_logs_agent ON ai_agent_logs("agentType");
CREATE INDEX idx_ai_agent_logs_lead ON ai_agent_logs("leadId");
CREATE INDEX idx_ai_agent_logs_session ON ai_agent_logs("sessionId");
CREATE INDEX idx_ai_agent_logs_action ON ai_agent_logs(action);
CREATE INDEX idx_ai_agent_logs_created ON ai_agent_logs("createdAt");

-- ============================================
-- ADICIONAR CHAVES ESTRANGEIRAS
-- ============================================

ALTER TABLE properties ADD CONSTRAINT fk_properties_owner FOREIGN KEY ("ownerId") REFERENCES owners(id) ON DELETE SET NULL;
ALTER TABLE property_images ADD CONSTRAINT fk_property_images_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE leads ADD CONSTRAINT fk_leads_property FOREIGN KEY ("interestedPropertyId") REFERENCES properties(id) ON DELETE SET NULL;
ALTER TABLE interactions ADD CONSTRAINT fk_interactions_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE CASCADE;
ALTER TABLE blog_posts ADD CONSTRAINT fk_blog_posts_author FOREIGN KEY ("authorId") REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE blog_posts ADD CONSTRAINT fk_blog_posts_category FOREIGN KEY ("categoryId") REFERENCES blog_categories(id) ON DELETE SET NULL;
ALTER TABLE analytics_events ADD CONSTRAINT fk_analytics_user FOREIGN KEY ("userId") REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE analytics_events ADD CONSTRAINT fk_analytics_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE analytics_events ADD CONSTRAINT fk_analytics_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE SET NULL;
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE SET NULL;
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE commissions ADD CONSTRAINT fk_commissions_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE commissions ADD CONSTRAINT fk_commissions_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE CASCADE;
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE rentals ADD CONSTRAINT fk_rentals_property FOREIGN KEY ("propertyId") REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE rental_payments ADD CONSTRAINT fk_rental_payments_rental FOREIGN KEY ("rentalId") REFERENCES rentals(id) ON DELETE CASCADE;
ALTER TABLE rental_expenses ADD CONSTRAINT fk_rental_expenses_rental FOREIGN KEY ("rentalId") REFERENCES rentals(id) ON DELETE CASCADE;
ALTER TABLE rental_contracts ADD CONSTRAINT fk_rental_contracts_rental FOREIGN KEY ("rentalId") REFERENCES rentals(id) ON DELETE CASCADE;
ALTER TABLE conversation_sessions ADD CONSTRAINT fk_conversation_sessions_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE chat_history ADD CONSTRAINT fk_chat_history_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE message_buffer ADD CONSTRAINT fk_message_buffer_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE ai_context_status ADD CONSTRAINT fk_ai_context_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE CASCADE;
ALTER TABLE client_interests ADD CONSTRAINT fk_client_interests_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE CASCADE;
ALTER TABLE ai_agent_logs ADD CONSTRAINT fk_ai_agent_logs_lead FOREIGN KEY ("leadId") REFERENCES leads(id) ON DELETE SET NULL;

-- ============================================
-- DADOS INICIAIS
-- ============================================

-- Inserir configurações padrão do site
INSERT INTO site_settings (key, value) VALUES
  ('site_name', 'Corretor das Mansões - Ernani Nunes'),
  ('site_email', 'ernanisimiao@hotmail.com'),
  ('site_phone', '(61) 98129-9575'),
  ('site_phone_raw', '5561981299575'),
  ('whatsapp_number', '5561981299575'),
  ('address', 'Brasília, DF'),
  ('instagram_url', 'https://instagram.com/corretordasmansoes'),
  ('youtube_url', 'https://youtube.com/@corretordasmansoes'),
  ('tiktok_url', 'https://tiktok.com/@corretordasmansoes'),
  ('facebook_url', ''),
  ('linkedin_url', ''),
  ('business_hours', 'Segunda a Sexta: 9h às 18h | Sábado: 9h às 13h'),
  ('about_text', 'Especialista em imóveis de alto padrão em Brasília'),
  ('creci', ''),
  ('enable_chat', 'true'),
  ('enable_n8n', 'true'),
  ('n8n_webhook_url', ''),
  ('ai_agent_enabled', 'true')
ON CONFLICT (key) DO NOTHING;

-- Inserir categorias de blog padrão
INSERT INTO blog_categories (name, slug, description) VALUES
  ('Mercado Imobiliário', 'mercado-imobiliario', 'Notícias e análises do mercado imobiliário'),
  ('Dicas para Compradores', 'dicas-compradores', 'Orientações para quem está comprando imóvel'),
  ('Dicas para Vendedores', 'dicas-vendedores', 'Orientações para quem está vendendo imóvel'),
  ('Financiamento', 'financiamento', 'Informações sobre financiamento imobiliário'),
  ('Decoração', 'decoracao', 'Dicas de decoração e design de interiores'),
  ('Investimentos', 'investimentos', 'Investimentos no mercado imobiliário')
ON CONFLICT (slug) DO NOTHING;

-- Inserir taxas de juros padrão (exemplo - atualizar com taxas reais)
INSERT INTO interest_rates (bank, "rateType", "annualRate", "monthlyRate", "validFrom", active) VALUES
  ('Caixa Econômica Federal', 'sac', 0.0899, 0.0072, CURRENT_DATE, true),
  ('Caixa Econômica Federal', 'price', 0.0949, 0.0076, CURRENT_DATE, true),
  ('Banco do Brasil', 'sac', 0.0879, 0.0070, CURRENT_DATE, true),
  ('Banco do Brasil', 'price', 0.0929, 0.0074, CURRENT_DATE, true),
  ('Bradesco', 'sac', 0.0919, 0.0074, CURRENT_DATE, true),
  ('Bradesco', 'price', 0.0969, 0.0078, CURRENT_DATE, true),
  ('Itaú', 'sac', 0.0909, 0.0073, CURRENT_DATE, true),
  ('Itaú', 'price', 0.0959, 0.0077, CURRENT_DATE, true),
  ('Santander', 'sac', 0.0929, 0.0075, CURRENT_DATE, true),
  ('Santander', 'price', 0.0979, 0.0079, CURRENT_DATE, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

-- Verificar tabelas criadas
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar enums criados
SELECT 
  t.typname as enum_name,
  array_agg(e.enumlabel ORDER BY e.enumsortorder) as enum_values
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'public'
GROUP BY t.typname
ORDER BY t.typname;

-- ============================================
-- FIM DO SCRIPT
-- ============================================
-- Total de tabelas: 32
-- Total de enums: 19
-- Sistema pronto para uso com agentes de IA e N8N!
-- ============================================
