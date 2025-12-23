import { pgTable, pgEnum, serial, text, timestamp, varchar, boolean, decimal, json, date, integer } from "drizzle-orm/pg-core";

// ============================================
// ENUMS
// ============================================

export const buyerProfileEnum = pgEnum("buyerProfile", [
    "investidor",
    "primeira_casa",
    "upgrade",
    "curioso",
    "indeciso"
  ]);
export const clientTypeEnum = pgEnum("clientType", [
    "comprador",
    "locatario",
    "proprietario"
  ]);
export const expenseTypeEnum = pgEnum("expenseType", [
    "manutencao",
    "limpeza",
    "reparos",
    "seguro",
    "iptu",
    "condominio",
    "agua",
    "luz",
    "internet",
    "outro"
  ]);
export const interestTypeEnum = pgEnum("interestType", ["venda", "locacao", "ambos"]);
export const paymentMethodEnum = pgEnum("paymentMethod", [
    "boleto",
    "pix",
    "transferencia",
    "dinheiro",
    "outro"
  ]);
export const priorityEnum = pgEnum("priority", ["baixa", "media", "alta", "urgente"]);
export const propertyTypeEnum = pgEnum("propertyType", [
    "casa",
    "apartamento",
    "cobertura",
    "terreno",
    "comercial",
    "rural",
    "lancamento"
  ]);
export const qualificationEnum = pgEnum("qualification", [
    "quente",
    "morno",
    "frio",
    "nao_qualificado"
  ]);
export const rateTypeEnum = pgEnum("rateType", ["sac", "price"]);
export const roleEnum = pgEnum("role", ["user", "admin"]);
export const sourceEnum = pgEnum("source", [
    "site",
    "whatsapp",
    "instagram",
    "facebook",
    "indicacao",
    "portal_zap",
    "portal_vivareal",
    "portal_olx",
    "google",
    "outro"
  ]);
export const stageEnum = pgEnum("stage", [
    "novo",
    "contato_inicial",
    "qualificado",
    "visita_agendada",
    "visita_realizada",
    "proposta",
    "negociacao",
    "fechado_ganho",
    "fechado_perdido",
    "sem_interesse"
  ]);
export const statusEnum = pgEnum("status", ["disponivel", "reservado", "vendido", "alugado", "inativo"]);
export const transactionInterestEnum = pgEnum("transactionInterest", ["venda", "locacao", "ambos"]);
export const transactionTypeEnum = pgEnum("transactionType", ["venda", "locacao", "ambos"]);
export const typeEnum = pgEnum("type", [
    "ligacao",
    "whatsapp",
    "email",
    "visita",
    "reuniao",
    "proposta",
    "nota",
    "status_change"
  ]);
export const urgencyLevelEnum = pgEnum("urgencyLevel", [
    "baixa",
    "media",
    "alta",
    "urgente"
  ]);


/**
 * Schema completo para o sistema Corretor das Mansões
 * Inclui: usuários, imóveis, leads, interações, blog, configurações
 */

// ============================================
// TABELA DE USUÁRIOS (AUTH)
// ============================================

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  openId: varchar("openId", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  loginMethod: varchar("loginMethod", { length: 64 }),
  role: roleEnum.default("user").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
  lastSignedIn: timestamp("lastSignedIn").defaultNow().notNull(),
});

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;

// ============================================
// TABELA DE IMÓVEIS
// ============================================

export const properties = pgTable("properties", {
  id: serial("id").primaryKey(),
  
  // Informações básicas
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description"),
  referenceCode: varchar("referenceCode", { length: 50 }).unique(),
  
  // Tipo e finalidade
  propertyType: propertyTypeEnum("propertyType").notNull(),
  transactionType: transactionTypeEnum("transactionType").notNull(),
  
  // Localização
  address: varchar("address", { length: 255 }),
  neighborhood: varchar("neighborhood", { length: 100 }),
  city: varchar("city", { length: 100 }),
  state: varchar("state", { length: 2 }),
  zipCode: varchar("zipCode", { length: 10 }),
  latitude: varchar("latitude", { length: 50 }),
  longitude: varchar("longitude", { length: 50 }),
  
  // Valores
  salePrice: integer("salePrice"), // em centavos
  rentPrice: integer("rentPrice"), // em centavos
  condoFee: integer("condoFee"), // em centavos
  iptu: integer("iptu"), // em centavos (anual)
  
  // Características
  bedrooms: integer("bedrooms"),
  bathrooms: integer("bathrooms"),
  suites: integer("suites"),
  parkingSpaces: integer("parkingSpaces"),
  totalArea: integer("totalArea"), // em m²
  builtArea: integer("builtArea"), // em m²
  
  // Características adicionais (JSON)
  features: text("features"), // JSON array: ["piscina", "churrasqueira", "academia"]
  
  // Imagens (JSON array de URLs)
  images: text("images"), // JSON array de objetos: [{url: "", caption: ""}]
  mainImage: varchar("mainImage", { length: 500 }),
  
  // Status e visibilidade
  status: statusEnum.default("disponivel").notNull(),
  featured: boolean("featured").default(false),
  published: boolean("published").default(true),
  
  // SEO
  metaTitle: varchar("metaTitle", { length: 255 }),
  metaDescription: text("metaDescription"),
  slug: varchar("slug", { length: 255 }).unique(),
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
  createdBy: integer("createdBy"),
});

export type Property = typeof properties.$inferSelect;
export type InsertProperty = typeof properties.$inferInsert;

// ============================================
// TABELA DE IMAGENS DE IMÓVEIS
// ============================================

export const propertyImages = pgTable("propertyImages", {
  id: serial("id").primaryKey(),
  propertyId: integer("propertyId").notNull(),
  imageUrl: varchar("imageUrl", { length: 500 }).notNull(),
  imageKey: varchar("imageKey", { length: 500 }).notNull(),
  isPrimary: integer("isPrimary").default(0).notNull(), // 1 = imagem principal, 0 = secundária
  displayOrder: integer("displayOrder").default(0).notNull(),
  caption: varchar("caption", { length: 255 }),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type PropertyImage = typeof propertyImages.$inferSelect;
export type InsertPropertyImage = typeof propertyImages.$inferInsert;

// ============================================
// TABELA DE LEADS/CLIENTES
// ============================================

export const leads = pgTable("leads", {
  id: serial("id").primaryKey(),
  
  // Informações pessoais
  name: varchar("name", { length: 255 }).notNull(),
  email: varchar("email", { length: 320 }),
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  
  // Origem do lead
  source: sourceEnum.default("site"),
  
  // Status no pipeline
  stage: stageEnum.default("novo").notNull(),
  
  // Perfil do cliente
  clientType: clientTypeEnum.default("comprador").notNull(),
  
  qualification: qualificationEnum.default("nao_qualificado").notNull(),
  
  buyerProfile: buyerProfileEnum,
  
  urgencyLevel: urgencyLevelEnum.default("media"),
  
  // Interesse
  interestedPropertyId: integer("interestedPropertyId"), // ID do imóvel de interesse
  transactionInterest: transactionInterestEnum.default("venda"),
  budgetMin: integer("budgetMin"), // em centavos
  budgetMax: integer("budgetMax"), // em centavos
  preferredNeighborhoods: text("preferredNeighborhoods"), // JSON array
  preferredPropertyTypes: text("preferredPropertyTypes"), // JSON array
  
  // Notas e tags
  notes: text("notes"),
  tags: text("tags"), // JSON array: ["vip", "urgente", "investidor"]
  
  // Atribuição
  assignedTo: integer("assignedTo"), // ID do usuário responsável
  
  // Score e prioridade
  score: integer("score").default(0), // 0-100
  priority: priorityEnum.default("media"),
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
  lastContactedAt: timestamp("lastContactedAt"),
  convertedAt: timestamp("convertedAt"),
});

export type Lead = typeof leads.$inferSelect;
export type InsertLead = typeof leads.$inferInsert;

// ============================================
// TABELA DE INTERAÇÕES/HISTÓRICO
// ============================================

export const interactions = pgTable("interactions", {
  id: serial("id").primaryKey(),
  
  leadId: integer("leadId").notNull(),
  userId: integer("userId"), // Quem fez a interação
  
  type: typeEnum("type").notNull(),
  
  subject: varchar("subject", { length: 255 }),
  description: text("description"),
  
  // Metadados específicos (JSON)
  metadata: text("metadata"), // Ex: {duration: 300, outcome: "positivo"}
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type Interaction = typeof interactions.$inferSelect;
export type InsertInteraction = typeof interactions.$inferInsert;

// ============================================
// TABELA DE BLOG POSTS
// ============================================

export const blogPosts = pgTable("blog_posts", {
  id: serial("id").primaryKey(),
  
  title: varchar("title", { length: 255 }).notNull(),
  slug: varchar("slug", { length: 255 }).unique().notNull(),
  excerpt: text("excerpt"),
  content: text("content").notNull(),
  
  featuredImage: varchar("featuredImage", { length: 500 }),
  
  categoryId: integer("categoryId"),
  authorId: integer("authorId"),
  
  // SEO
  metaTitle: varchar("metaTitle", { length: 255 }),
  metaDescription: text("metaDescription"),
  
  // Status
  published: boolean("published").default(false),
  publishedAt: timestamp("publishedAt"),
  
  // Estatísticas
  views: integer("views").default(0),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type BlogPost = typeof blogPosts.$inferSelect;
export type InsertBlogPost = typeof blogPosts.$inferInsert;

// ============================================
// TABELA DE CATEGORIAS DE BLOG
// ============================================

export const blogCategories = pgTable("blog_categories", {
  id: serial("id").primaryKey(),
  
  name: varchar("name", { length: 100 }).notNull(),
  slug: varchar("slug", { length: 100 }).unique().notNull(),
  description: text("description"),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type BlogCategory = typeof blogCategories.$inferSelect;
export type InsertBlogCategory = typeof blogCategories.$inferInsert;

// ============================================
// TABELA DE CONFIGURAÇÕES DO SITE
// ============================================

export const siteSettings = pgTable("site_settings", {
  id: serial("id").primaryKey(),
  
  // Informações da empresa
  companyName: varchar("companyName", { length: 255 }),
  companyDescription: text("companyDescription"),
  companyLogo: varchar("companyLogo", { length: 500 }),
  
  // Informações do corretor
  realtorName: varchar("realtorName", { length: 255 }),
  realtorPhoto: varchar("realtorPhoto", { length: 500 }),
  realtorBio: text("realtorBio"),
  realtorCreci: varchar("realtorCreci", { length: 50 }),
  
  // Contatos
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  email: varchar("email", { length: 320 }),
  address: text("address"),
  
  // Redes sociais
  instagram: varchar("instagram", { length: 255 }),
  facebook: varchar("facebook", { length: 255 }),
  youtube: varchar("youtube", { length: 255 }),
  tiktok: varchar("tiktok", { length: 255 }),
  linkedin: varchar("linkedin", { length: 255 }),
  
  // SEO
  siteTitle: varchar("siteTitle", { length: 255 }),
  siteDescription: text("siteDescription"),
  siteKeywords: text("siteKeywords"),
  
  // Integrações
  googleAnalyticsId: varchar("googleAnalyticsId", { length: 50 }),
  facebookPixelId: varchar("facebookPixelId", { length: 50 }),
  
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type SiteSetting = typeof siteSettings.$inferSelect;
export type InsertSiteSetting = typeof siteSettings.$inferInsert;

// ============================================
// TABELAS DE INTEGRAÇÃO WHATSAPP / N8N
// ============================================

// Buffer de mensagens do WhatsApp
export const messageBuffer = pgTable("message_buffer", {
  id: serial("id").primaryKey(),
  phone: varchar("phone", { length: 20 }).notNull(),
  messageId: varchar("messageId", { length: 255 }).notNull().unique(),
  content: text("content"),
  type: typeEnum("type").notNull(),
  timestamp: timestamp("timestamp").defaultNow().notNull(),
  processed: integer("processed").default(0).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type MessageBuffer = typeof messageBuffer.$inferSelect;
export type InsertMessageBuffer = typeof messageBuffer.$inferInsert;

// Contexto e histórico de IA
export const aiContextStatus = pgTable("ai_context_status", {
  id: serial("id").primaryKey(),
  sessionId: varchar("sessionId", { length: 255 }).notNull(),
  phone: varchar("phone", { length: 20 }).notNull(),
  message: text("message").notNull(), // JSON com {type: 'ai'|'user', content: string}
  role: roleEnum("role").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type AiContextStatus = typeof aiContextStatus.$inferSelect;
export type InsertAiContextStatus = typeof aiContextStatus.$inferInsert;

// Interesses dos clientes (para N8N)
export const clientInterests = pgTable("client_interests", {
  id: serial("id").primaryKey(),
  clientId: integer("clientId").notNull(), // Referência ao lead
  propertyType: varchar("propertyType", { length: 100 }), // Tipo de imóvel de interesse
  interestType: interestTypeEnum,
  budgetMin: integer("budgetMin"), // Em centavos
  budgetMax: integer("budgetMax"), // Em centavos
  preferredNeighborhoods: text("preferredNeighborhoods"),
  notes: text("notes"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type ClientInterest = typeof clientInterests.$inferSelect;
export type InsertClientInterest = typeof clientInterests.$inferInsert;

// Webhooks e logs de integração
export const webhookLogs = pgTable("webhook_logs", {
  id: serial("id").primaryKey(),
  source: varchar("source", { length: 50 }).notNull(), // whatsapp, n8n, etc
  event: varchar("event", { length: 100 }).notNull(),
  payload: text("payload"), // JSON do payload recebido
  response: text("response"), // JSON da resposta enviada
  status: statusEnum("status").notNull(),
  errorMessage: text("errorMessage"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type WebhookLog = typeof webhookLogs.$inferSelect;
export type InsertWebhookLog = typeof webhookLogs.$inferInsert;

// ============================================
// TABELA DE PROPRIETÁRIOS
// ============================================

export const owners = pgTable("owners", {
  id: serial("id").primaryKey(),
  
  // Informações pessoais
  name: varchar("name", { length: 255 }).notNull(),
  cpfCnpj: varchar("cpfCnpj", { length: 20 }),
  email: varchar("email", { length: 320 }),
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  
  // Endereço
  address: text("address"),
  city: varchar("city", { length: 100 }),
  state: varchar("state", { length: 2 }),
  zipCode: varchar("zipCode", { length: 10 }),
  
  // Informações bancárias (para pagamentos)
  bankName: varchar("bankName", { length: 100 }),
  bankAgency: varchar("bankAgency", { length: 20 }),
  bankAccount: varchar("bankAccount", { length: 30 }),
  pixKey: varchar("pixKey", { length: 255 }),
  
  // Notas e observações
  notes: text("notes"),
  
  // Status
  active: boolean("active").default(true),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Owner = typeof owners.$inferSelect;
export type InsertOwner = typeof owners.$inferInsert;

// ============================================
// TABELAS DE ANALYTICS E MÉTRICAS
// ============================================

export const analyticsEvents = pgTable("analytics_events", {
  id: serial("id").primaryKey(),
  
  // Tipo de evento
  eventType: varchar("eventType", { length: 50 }).notNull(), // page_view, property_view, contact_form, whatsapp_click, phone_click
  
  // Dados do evento
  propertyId: integer("propertyId"),
  leadId: integer("leadId"),
  userId: integer("userId"),
  
  // Origem do tráfego
  source: varchar("source", { length: 100 }), // google_ads, facebook_ads, instagram, organic, direct
  medium: varchar("medium", { length: 100 }), // cpc, social, organic, referral
  campaign: varchar("campaign", { length: 255 }), // Nome da campanha
  
  // Dados técnicos
  url: varchar("url", { length: 500 }),
  referrer: varchar("referrer", { length: 500 }),
  userAgent: text("userAgent"),
  ipAddress: varchar("ipAddress", { length: 45 }),
  
  // Metadados
  metadata: json("metadata"), // Dados adicionais em JSON
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export type AnalyticsEvent = typeof analyticsEvents.$inferSelect;
export type InsertAnalyticsEvent = typeof analyticsEvents.$inferInsert;

export const campaignSources = pgTable("campaign_sources", {
  id: serial("id").primaryKey(),
  
  // Identificação da campanha
  name: varchar("name", { length: 255 }).notNull(),
  source: varchar("source", { length: 100 }).notNull(), // google, facebook, instagram, etc
  medium: varchar("medium", { length: 100 }), // cpc, social, etc
  campaignId: varchar("campaignId", { length: 255 }), // ID externo da campanha
  
  // Métricas
  budget: decimal("budget", { precision: 10, scale: 2 }), // Orçamento investido
  clicks: integer("clicks").default(0),
  impressions: integer("impressions").default(0),
  conversions: integer("conversions").default(0), // Leads gerados
  
  // Status
  active: boolean("active").default(true),
  startDate: date("startDate"),
  endDate: date("endDate"),
  
  // Notas
  notes: text("notes"),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type CampaignSource = typeof campaignSources.$inferSelect;
export type InsertCampaignSource = typeof campaignSources.$inferInsert;

// ============================================
// TABELAS FINANCEIRAS
// ============================================

export const transactions = pgTable("transactions", {
  id: serial("id").primaryKey(),
  
  // Tipo de transação
  type: varchar("type", { length: 50 }).notNull(), // commission, expense, revenue
  category: varchar("category", { length: 100 }), // sale_commission, marketing, office, etc
  
  // Valores
  amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
  currency: varchar("currency", { length: 3 }).default("BRL"),
  
  // Relacionamentos
  propertyId: integer("propertyId"), // Imóvel relacionado
  leadId: integer("leadId"), // Cliente relacionado
  ownerId: integer("ownerId"), // Proprietário relacionado
  
  // Descrição
  description: text("description").notNull(),
  notes: text("notes"),
  
  // Status de pagamento
  status: varchar("status", { length: 50 }).default("pending"), // pending, paid, cancelled
  paymentMethod: varchar("paymentMethod", { length: 50 }), // pix, transfer, check, cash
  paymentDate: date("paymentDate"),
  dueDate: date("dueDate"),
  
  // Comprovantes
  receiptUrl: varchar("receiptUrl", { length: 500 }),
  invoiceNumber: varchar("invoiceNumber", { length: 100 }),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Transaction = typeof transactions.$inferSelect;
export type InsertTransaction = typeof transactions.$inferInsert;

export const commissions = pgTable("commissions", {
  id: serial("id").primaryKey(),
  
  // Venda relacionada
  propertyId: integer("propertyId").notNull(),
  leadId: integer("leadId").notNull(), // Comprador
  ownerId: integer("ownerId"), // Vendedor
  
  // Valores da venda
  salePrice: decimal("salePrice", { precision: 12, scale: 2 }).notNull(),
  commissionRate: decimal("commissionRate", { precision: 5, scale: 2 }).notNull(), // Percentual (ex: 6.00 para 6%)
  commissionAmount: decimal("commissionAmount", { precision: 12, scale: 2 }).notNull(),
  
  // Divisão de comissão (se houver)
  splitWithAgent: boolean("splitWithAgent").default(false),
  agentName: varchar("agentName", { length: 255 }),
  agentCommissionAmount: decimal("agentCommissionAmount", { precision: 12, scale: 2 }),
  
  // Status
  status: varchar("status", { length: 50 }).default("pending"), // pending, paid, cancelled
  paymentDate: date("paymentDate"),
  
  // Notas
  notes: text("notes"),
  
  // Transação financeira relacionada
  transactionId: integer("transactionId"),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Commission = typeof commissions.$inferSelect;
export type InsertCommission = typeof commissions.$inferInsert;

// ============================================
// TABELA DE AVALIAÇÕES DE CLIENTES
// ============================================

export const reviews = pgTable("reviews", {
  id: serial("id").primaryKey(),
  
  // Informações do cliente
  clientName: varchar("clientName", { length: 255 }).notNull(),
  clientRole: varchar("clientRole", { length: 100 }), // Empresário, Médico, etc
  clientPhoto: varchar("clientPhoto", { length: 500 }),
  
  // Avaliação
  rating: integer("rating").notNull(), // 1 a 5 estrelas
  title: varchar("title", { length: 255 }),
  content: text("content").notNull(),
  
  // Relacionamentos (opcional)
  propertyId: integer("propertyId"), // Imóvel avaliado
  leadId: integer("leadId"), // Cliente do CRM
  
  // Status
  approved: boolean("approved").default(false),
  featured: boolean("featured").default(false), // Destacar na home
  
  // Metadados
  displayOrder: integer("displayOrder").default(0),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Review = typeof reviews.$inferSelect;
export type InsertReview = typeof reviews.$inferInsert;


// ============================================
// TABELA DE PIPELINE DE VENDAS (CRM)
// ============================================

export const salesPipeline = pgTable("sales_pipeline", {
  id: serial("id").primaryKey(),
  
  leadId: integer("leadId").notNull(),
  propertyId: integer("propertyId"),
  
  // Estágio do pipeline
  stage: stageEnum.default("novo").notNull(),
  
  // Probabilidade de fechamento (%)
  probability: integer("probability").default(0),
  
  // Valor estimado da transação
  estimatedValue: integer("estimatedValue"), // em centavos
  
  // Datas importantes
  enteredAt: timestamp("enteredAt").defaultNow().notNull(),
  expectedCloseDate: date("expectedCloseDate"),
  closedAt: timestamp("closedAt"),
  
  // Notas
  notes: text("notes"),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type SalesPipeline = typeof salesPipeline.$inferSelect;
export type InsertSalesPipeline = typeof salesPipeline.$inferInsert;

// ============================================
// TABELA DE TAREFAS/FOLLOW-UP (CRM)
// ============================================

export const tasks = pgTable("tasks", {
  id: serial("id").primaryKey(),
  
  leadId: integer("leadId").notNull(),
  assignedTo: integer("assignedTo"), // ID do usuário
  
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description"),
  
  type: typeEnum("type").notNull(),
  
  priority: priorityEnum.default("media"),
  
  status: statusEnum.default("pendente"),
  
  dueDate: date("dueDate"),
  completedAt: timestamp("completedAt"),
  
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Task = typeof tasks.$inferSelect;
export type InsertTask = typeof tasks.$inferInsert;




// ============================================
// TABELA DE TAXAS DE JUROS PARA SIMULADOR
// ============================================

export const interestRates = pgTable("interestRates", {
  id: serial("id").primaryKey(),
  
  bankName: varchar("bankName", { length: 100 }).notNull(),
  rateType: rateTypeEnum("rateType").notNull(),
  annualRate: decimal("annualRate", { precision: 5, scale: 3 }).notNull(), // Ex: 8.500 para 8.5%
  startDate: date("startDate").notNull(),
  endDate: date("endDate"),
  
  // Metadados
  source: varchar("source", { length: 255 }),
  lastUpdated: timestamp("lastUpdated").defaultNow().notNull(),
});

export type InterestRate = typeof interestRates.$inferSelect;
export type InsertInterestRate = typeof interestRates.$inferInsert;

// ============================================
// TABELA DE ALUGU\u00c9IS (RENTAL MANAGEMENT)
// ============================================

export const rentals = pgTable("rentals", {
  id: serial("id").primaryKey(),
  
  // Refer\u00eancias
  propertyId: integer("propertyId").notNull(),
  tenantId: integer("tenantId").notNull(), // Lead/Cliente que \u00e9 o inquilino
  ownerId: integer("ownerId").notNull(), // Propriet\u00e1rio do im\u00f3vel
  
  // Valores
  monthlyRent: integer("monthlyRent").notNull(), // em centavos
  commissionPercentage: decimal("commissionPercentage", { precision: 5, scale: 2 }).default(0), // % de comiss\u00e3o
  commissionAmount: integer("commissionAmount").default(0), // em centavos
  
  // Datas
  startDate: date("startDate").notNull(),
  endDate: date("endDate"),
  
  // Status
  status: statusEnum.default("ativo").notNull(),
  
  // Contrato
  contractUrl: varchar("contractUrl", { length: 500 }),
  contractGeneratedAt: timestamp("contractGeneratedAt"),
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type Rental = typeof rentals.$inferSelect;
export type InsertRental = typeof rentals.$inferInsert;

// ============================================
// TABELA DE PAGAMENTOS DE ALUGU\u00c9IS
// ============================================

export const rentalPayments = pgTable("rentalPayments", {
  id: serial("id").primaryKey(),
  
  rentalId: integer("rentalId").notNull(),
  tenantId: integer("tenantId").notNull(),
  
  // Valores
  amount: integer("amount").notNull(), // em centavos
  commission: integer("commission").default(0), // em centavos
  
  // Data de vencimento e pagamento
  dueDate: date("dueDate").notNull(),
  paidDate: date("paidDate"),
  
  // M\u00e9todo de pagamento
  paymentMethod: paymentMethodEnum("paymentMethod").notNull(),
  
  // Status
  status: statusEnum.default("pendente").notNull(),
  
  // Refer\u00eancias de pagamento
  paymentReference: varchar("paymentReference", { length: 255 }), // N\u00famero do boleto, ID do Pix, etc
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type RentalPayment = typeof rentalPayments.$inferSelect;
export type InsertRentalPayment = typeof rentalPayments.$inferInsert;

// ============================================
// TABELA DE DESPESAS DE ALUGU\u00c9IS
// ============================================

export const rentalExpenses = pgTable("rentalExpenses", {
  id: serial("id").primaryKey(),
  
  rentalId: integer("rentalId").notNull(),
  propertyId: integer("propertyId").notNull(),
  
  // Tipo de despesa
  expenseType: expenseTypeEnum("expenseType").notNull(),
  
  // Valores
  amount: integer("amount").notNull(), // em centavos
  description: text("description"),
  
  // Data
  expenseDate: date("expenseDate").notNull(),
  
  // Status
  status: statusEnum.default("pendente").notNull(),
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type RentalExpense = typeof rentalExpenses.$inferSelect;
export type InsertRentalExpense = typeof rentalExpenses.$inferInsert;

// ============================================
// TABELA DE CONTRATOS DE ALUGU\u00c9L
// ============================================

export const rentalContracts = pgTable("rentalContracts", {
  id: serial("id").primaryKey(),
  
  rentalId: integer("rentalId").notNull(),
  
  // Dados do contrato
  contractNumber: varchar("contractNumber", { length: 100 }).unique(),
  contractUrl: varchar("contractUrl", { length: 500 }),
  
  // Dados do inquilino
  tenantName: varchar("tenantName", { length: 255 }).notNull(),
  tenantCpf: varchar("tenantCpf", { length: 20 }),
  tenantEmail: varchar("tenantEmail", { length: 320 }),
  tenantPhone: varchar("tenantPhone", { length: 20 }),
  
  // Dados do propriet\u00e1rio
  ownerName: varchar("ownerName", { length: 255 }).notNull(),
  ownerCpf: varchar("ownerCpf", { length: 20 }),
  
  // Dados do im\u00f3vel
  propertyAddress: varchar("propertyAddress", { length: 500 }).notNull(),
  
  // Valores
  monthlyRent: integer("monthlyRent").notNull(),
  
  // Datas
  startDate: date("startDate").notNull(),
  endDate: date("endDate"),
  signedDate: date("signedDate"),
  
  // Status
  status: statusEnum.default("rascunho").notNull(),
  
  // Timestamps
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().notNull(),
});

export type RentalContract = typeof rentalContracts.$inferSelect;
export type InsertRentalContract = typeof rentalContracts.$inferInsert;
