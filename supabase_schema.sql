-- ============================================
-- SCRIPT SQL COMPLETO PARA SUPABASE
-- Sistema: Corretor das Mansões
-- Banco: PostgreSQL 16
-- ============================================

-- Limpar tabelas existentes (use com cuidado em produção)
-- DROP TABLE IF EXISTS rental_contracts CASCADE;
-- DROP TABLE IF EXISTS rental_expenses CASCADE;
-- DROP TABLE IF EXISTS rental_payments CASCADE;
-- DROP TABLE IF EXISTS rentals CASCADE;
-- DROP TABLE IF EXISTS interest_rates CASCADE;
-- DROP TABLE IF EXISTS reviews CASCADE;
-- DROP TABLE IF EXISTS commissions CASCADE;
-- DROP TABLE IF EXISTS transactions CASCADE;
-- DROP TABLE IF EXISTS analytics CASCADE;
-- DROP TABLE IF EXISTS owners CASCADE;
-- DROP TABLE IF EXISTS settings CASCADE;
-- DROP TABLE IF EXISTS blog_posts CASCADE;
-- DROP TABLE IF EXISTS interactions CASCADE;
-- DROP TABLE IF EXISTS leads CASCADE;
-- DROP TABLE IF EXISTS properties CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- DROP TYPE IF EXISTS role_enum CASCADE;
-- DROP TYPE IF EXISTS property_type_enum CASCADE;
-- DROP TYPE IF EXISTS transaction_type_enum CASCADE;
-- DROP TYPE IF EXISTS stage_enum CASCADE;
-- DROP TYPE IF EXISTS source_enum CASCADE;
-- DROP TYPE IF EXISTS priority_enum CASCADE;
-- DROP TYPE IF EXISTS qualification_enum CASCADE;
-- DROP TYPE IF EXISTS buyer_profile_enum CASCADE;
-- DROP TYPE IF EXISTS urgency_level_enum CASCADE;
-- DROP TYPE IF EXISTS transaction_interest_enum CASCADE;
-- DROP TYPE IF EXISTS status_enum CASCADE;
-- DROP TYPE IF EXISTS type_enum CASCADE;
-- DROP TYPE IF EXISTS client_type_enum CASCADE;
-- DROP TYPE IF EXISTS rate_type_enum CASCADE;
-- DROP TYPE IF EXISTS interest_type_enum CASCADE;
-- DROP TYPE IF EXISTS payment_method_enum CASCADE;
-- DROP TYPE IF EXISTS expense_type_enum CASCADE;

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
  images JSON,
  "videoUrl" TEXT,
  "virtualTourUrl" TEXT,
  
  -- Status e destaque
  status status_enum NOT NULL DEFAULT 'ativo',
  featured BOOLEAN DEFAULT FALSE,
  
  -- Relacionamento com proprietário
  "ownerId" INTEGER REFERENCES owners(id) ON DELETE SET NULL,
  
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
  "interestedPropertyId" INTEGER REFERENCES properties(id) ON DELETE SET NULL,
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

-- ============================================
-- TABELA DE INTERAÇÕES
-- ============================================

CREATE TABLE interactions (
  id SERIAL PRIMARY KEY,
  "leadId" INTEGER NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  description TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_interactions_lead ON interactions("leadId");
CREATE INDEX idx_interactions_type ON interactions(type);

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
  "authorId" INTEGER REFERENCES users(id) ON DELETE SET NULL,
  published BOOLEAN DEFAULT FALSE,
  "publishedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_blog_slug ON blog_posts(slug);
CREATE INDEX idx_blog_published ON blog_posts(published);
CREATE INDEX idx_blog_author ON blog_posts("authorId");

-- ============================================
-- TABELA DE CONFIGURAÇÕES
-- ============================================

CREATE TABLE settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(100) NOT NULL UNIQUE,
  value TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_settings_key ON settings(key);

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

CREATE TABLE analytics (
  id SERIAL PRIMARY KEY,
  event VARCHAR(100) NOT NULL,
  data JSON,
  "userId" INTEGER REFERENCES users(id) ON DELETE SET NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_analytics_event ON analytics(event);
CREATE INDEX idx_analytics_user ON analytics("userId");
CREATE INDEX idx_analytics_created ON analytics("createdAt");

-- ============================================
-- TABELA DE TRANSAÇÕES FINANCEIRAS
-- ============================================

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  type type_enum NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  description TEXT,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE SET NULL,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE SET NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_property ON transactions("propertyId");
CREATE INDEX idx_transactions_lead ON transactions("leadId");

-- ============================================
-- TABELA DE COMISSÕES
-- ============================================

CREATE TABLE commissions (
  id SERIAL PRIMARY KEY,
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE CASCADE,
  "leadId" INTEGER REFERENCES leads(id) ON DELETE CASCADE,
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
  "propertyId" INTEGER REFERENCES properties(id) ON DELETE CASCADE,
  "clientName" VARCHAR(255) NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  approved BOOLEAN DEFAULT FALSE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reviews_property ON reviews("propertyId");
CREATE INDEX idx_reviews_approved ON reviews(approved);

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
  "propertyId" INTEGER NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
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
  "rentalId" INTEGER NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
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
  "rentalId" INTEGER NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
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
  "rentalId" INTEGER NOT NULL UNIQUE REFERENCES rentals(id) ON DELETE CASCADE,
  "contractUrl" TEXT,
  "signedDate" DATE,
  notes TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_contracts_rental ON rental_contracts("rentalId");

-- ============================================
-- DADOS INICIAIS (OPCIONAL)
-- ============================================

-- Inserir configurações padrão
INSERT INTO settings (key, value) VALUES
  ('site_name', 'Corretor das Mansões - Ernani Nunes'),
  ('site_email', 'ernanisimiao@hotmail.com'),
  ('site_phone', '(61) 98129-9575'),
  ('whatsapp_number', '5561981299575'),
  ('address', 'Brasília, DF'),
  ('instagram_url', 'https://instagram.com/corretordasmansoes'),
  ('youtube_url', 'https://youtube.com/@corretordasmansoes'),
  ('tiktok_url', 'https://tiktok.com/@corretordasmansoes')
ON CONFLICT (key) DO NOTHING;

-- Inserir taxas de juros padrão (exemplo)
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
-- FIM DO SCRIPT
-- ============================================

-- Verificar tabelas criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
