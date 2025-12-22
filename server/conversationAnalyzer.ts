import { invokeLLM } from "./_core/llm";

/**
 * Interface para o resultado da análise de conversa
 */
export interface ConversationAnalysis {
  // Perfil do cliente
  budget?: {
    min: number;
    max: number;
    currency: string;
  };
  preferences?: {
    propertyType?: string[]; // casa, apartamento, cobertura, etc
    bedrooms?: number;
    bathrooms?: number;
    area?: number;
    features?: string[]; // piscina, churrasqueira, garagem, etc
  };
  location?: {
    neighborhoods?: string[];
    city?: string;
    state?: string;
  };
  
  // Qualificação do lead
  qualification: "hot" | "warm" | "cold";
  qualificationReason: string;
  
  // Intenção
  intent: "buy" | "rent" | "both" | "unknown";
  urgency: "high" | "medium" | "low";
  
  // Resumo
  summary: string;
  nextSteps: string[];
}

/**
 * Analisa uma conversa WhatsApp e extrai informações do cliente
 */
export async function analyzeConversation(
  messages: Array<{ role: "user" | "assistant"; content: string; timestamp: Date }>
): Promise<ConversationAnalysis> {
  // Montar histórico de conversa para o LLM
  const conversationText = messages
    .map((msg) => `[${msg.timestamp.toISOString()}] ${msg.role === "user" ? "Cliente" : "Atendente"}: ${msg.content}`)
    .join("\n");

  const systemPrompt = `Você é um assistente especializado em análise de conversas imobiliárias. 
Analise a conversa abaixo e extraia as seguintes informações do cliente em formato JSON:

{
  "budget": {
    "min": número ou null,
    "max": número ou null,
    "currency": "BRL"
  },
  "preferences": {
    "propertyType": array de strings ou null,
    "bedrooms": número ou null,
    "bathrooms": número ou null,
    "area": número em m² ou null,
    "features": array de strings ou null
  },
  "location": {
    "neighborhoods": array de strings ou null,
    "city": string ou null,
    "state": string ou null
  },
  "qualification": "hot" | "warm" | "cold",
  "qualificationReason": "explicação breve da qualificação",
  "intent": "buy" | "rent" | "both" | "unknown",
  "urgency": "high" | "medium" | "low",
  "summary": "resumo da conversa em 2-3 frases",
  "nextSteps": array de strings com próximas ações recomendadas
}

**Critérios de qualificação:**
- **hot**: Cliente com orçamento definido, urgência alta, já visitou imóveis ou quer agendar visita
- **warm**: Cliente interessado, mas sem urgência ou orçamento indefinido
- **cold**: Cliente apenas pesquisando, sem intenção clara de compra/aluguel

**Critérios de urgência:**
- **high**: Quer visitar em menos de 1 semana, precisa mudar logo, já vendeu imóvel atual
- **medium**: Quer visitar em 1-4 semanas, procurando ativamente
- **low**: Apenas pesquisando, sem prazo definido

Se alguma informação não estiver na conversa, retorne null para esse campo.`;

  try {
    const response = await invokeLLM({
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: `Conversa:\n\n${conversationText}` },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "conversation_analysis",
          strict: true,
          schema: {
            type: "object",
            properties: {
              budget: {
                type: "object",
                properties: {
                  min: { type: ["number", "null"] },
                  max: { type: ["number", "null"] },
                  currency: { type: "string" },
                },
                required: ["min", "max", "currency"],
                additionalProperties: false,
              },
              preferences: {
                type: "object",
                properties: {
                  propertyType: { type: ["array", "null"], items: { type: "string" } },
                  bedrooms: { type: ["number", "null"] },
                  bathrooms: { type: ["number", "null"] },
                  area: { type: ["number", "null"] },
                  features: { type: ["array", "null"], items: { type: "string" } },
                },
                required: ["propertyType", "bedrooms", "bathrooms", "area", "features"],
                additionalProperties: false,
              },
              location: {
                type: "object",
                properties: {
                  neighborhoods: { type: ["array", "null"], items: { type: "string" } },
                  city: { type: ["string", "null"] },
                  state: { type: ["string", "null"] },
                },
                required: ["neighborhoods", "city", "state"],
                additionalProperties: false,
              },
              qualification: { type: "string", enum: ["hot", "warm", "cold"] },
              qualificationReason: { type: "string" },
              intent: { type: "string", enum: ["buy", "rent", "both", "unknown"] },
              urgency: { type: "string", enum: ["high", "medium", "low"] },
              summary: { type: "string" },
              nextSteps: { type: "array", items: { type: "string" } },
            },
            required: [
              "budget",
              "preferences",
              "location",
              "qualification",
              "qualificationReason",
              "intent",
              "urgency",
              "summary",
              "nextSteps",
            ],
            additionalProperties: false,
          },
        },
      },
    });

    const content = response.choices[0].message.content;
    if (!content || typeof content !== "string") {
      throw new Error("LLM retornou resposta vazia ou inválida");
    }

    const analysis: ConversationAnalysis = JSON.parse(content);
    return analysis;
  } catch (error) {
    console.error("Erro ao analisar conversa:", error);
    
    // Retornar análise padrão em caso de erro
    return {
      qualification: "cold",
      qualificationReason: "Análise automática falhou - requer revisão manual",
      intent: "unknown",
      urgency: "low",
      summary: "Erro ao processar conversa automaticamente",
      nextSteps: ["Revisar conversa manualmente", "Entrar em contato com o cliente"],
    };
  }
}

/**
 * Atualiza um lead com as informações extraídas da análise
 */
export function mapAnalysisToLeadData(analysis: ConversationAnalysis) {
  return {
    // Qualificação
    qualification: analysis.qualification,
    qualificationNotes: analysis.qualificationReason,
    
    // Intenção e urgência
    intent: analysis.intent,
    urgency: analysis.urgency,
    
    // Orçamento
    budgetMin: analysis.budget?.min || null,
    budgetMax: analysis.budget?.max || null,
    
    // Preferências
    preferredPropertyTypes: analysis.preferences?.propertyType?.join(", ") || null,
    preferredBedrooms: analysis.preferences?.bedrooms || null,
    preferredBathrooms: analysis.preferences?.bathrooms || null,
    preferredArea: analysis.preferences?.area || null,
    preferredFeatures: analysis.preferences?.features?.join(", ") || null,
    
    // Localização
    preferredNeighborhoods: analysis.location?.neighborhoods?.join(", ") || null,
    preferredCity: analysis.location?.city || null,
    preferredState: analysis.location?.state || null,
    
    // Resumo e próximos passos
    notes: `${analysis.summary}\n\nPróximos passos:\n${analysis.nextSteps.map((step, i) => `${i + 1}. ${step}`).join("\n")}`,
  };
}
