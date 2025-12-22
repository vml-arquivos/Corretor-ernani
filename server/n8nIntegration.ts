// server/n8nIntegration.ts

/**
 * Módulo de Integração com N8N
 * Gerencia webhooks e automações com N8N para fluxos de CRM inteligente
 */

import { z } from "zod";

// ============================================
// SCHEMAS
// ============================================

export const N8NWebhookSchema = z.object({
  event: z.enum([
    "lead_created",
    "lead_updated",
    "lead_converted",
    "payment_received",
    "payment_overdue",
    "rental_created",
    "rental_ended",
    "contract_signed",
  ]),
  data: z.record(z.any()),
  timestamp: z.string().optional(),
});

export const N8NAutomationSchema = z.object({
  name: z.string(),
  trigger: z.string(),
  actions: z.array(z.object({
    type: z.string(),
    config: z.record(z.any()),
  })),
  enabled: z.boolean().default(true),
});

// ============================================
// TIPOS
// ============================================

export type N8NWebhookPayload = z.infer<typeof N8NWebhookSchema>;
export type N8NAutomation = z.infer<typeof N8NAutomationSchema>;

// ============================================
// CONFIGURAÇÕES
// ============================================

const N8N_WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || "http://localhost:5678/webhook";
const N8N_API_KEY = process.env.N8N_API_KEY || "";

// ============================================
// FUNÇÕES DE INTEGRAÇÃO
// ============================================

/**
 * Envia um webhook para N8N
 */
export async function sendN8NWebhook(payload: N8NWebhookPayload): Promise<void> {
  try {
    const response = await fetch(N8N_WEBHOOK_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${N8N_API_KEY}`,
      },
      body: JSON.stringify({
        ...payload,
        timestamp: new Date().toISOString(),
      }),
    });

    if (!response.ok) {
      console.error(`N8N webhook failed: ${response.statusText}`);
    }
  } catch (error) {
    console.error("Error sending N8N webhook:", error);
    // Não lançar erro para não interromper o fluxo principal
  }
}

/**
 * Dispara automação de follow-up para um lead
 */
export async function triggerLeadFollowUp(leadId: number, leadData: {
  name: string;
  email?: string;
  phone?: string;
  stage: string;
  score: number;
}): Promise<void> {
  await sendN8NWebhook({
    event: "lead_updated",
    data: {
      leadId,
      ...leadData,
      action: "follow_up",
    },
  });
}

/**
 * Dispara automação de análise de perfil do cliente
 */
export async function triggerClientAnalysis(leadId: number, interactions: any[]): Promise<void> {
  await sendN8NWebhook({
    event: "lead_updated",
    data: {
      leadId,
      action: "analyze_profile",
      interactionCount: interactions.length,
      lastInteraction: interactions[interactions.length - 1]?.createdAt,
    },
  });
}

/**
 * Dispara automação de notificação de pagamento atrasado
 */
export async function triggerOverduePaymentNotification(
  rentalId: number,
  tenantId: number,
  amount: number,
  daysOverdue: number
): Promise<void> {
  await sendN8NWebhook({
    event: "payment_overdue",
    data: {
      rentalId,
      tenantId,
      amount,
      daysOverdue,
      action: "notify_overdue",
    },
  });
}

/**
 * Dispara automação de envio de contrato
 */
export async function triggerContractSending(
  contractId: number,
  tenantEmail: string,
  contractUrl: string
): Promise<void> {
  await sendN8NWebhook({
    event: "contract_signed",
    data: {
      contractId,
      tenantEmail,
      contractUrl,
      action: "send_contract",
    },
  });
}

/**
 * Dispara automação de geração de boleto
 */
export async function triggerBoletoGeneration(
  paymentId: number,
  amount: number,
  dueDate: string,
  recipientEmail: string
): Promise<void> {
  await sendN8NWebhook({
    event: "payment_received",
    data: {
      paymentId,
      amount,
      dueDate,
      recipientEmail,
      action: "generate_boleto",
    },
  });
}

/**
 * Dispara automação de envio de PIX
 */
export async function triggerPixGeneration(
  paymentId: number,
  amount: number,
  dueDate: string,
  recipientPhone: string
): Promise<void> {
  await sendN8NWebhook({
    event: "payment_received",
    data: {
      paymentId,
      amount,
      dueDate,
      recipientPhone,
      action: "generate_pix",
    },
  });
}

/**
 * Dispara automação de envio de lembrança de pagamento
 */
export async function triggerPaymentReminder(
  rentalId: number,
  tenantName: string,
  tenantPhone: string,
  amount: number,
  dueDate: string
): Promise<void> {
  await sendN8NWebhook({
    event: "lead_updated",
    data: {
      rentalId,
      tenantName,
      tenantPhone,
      amount,
      dueDate,
      action: "payment_reminder",
    },
  });
}

/**
 * Dispara automação de envio de imóvel recomendado
 */
export async function triggerPropertyRecommendation(
  leadId: number,
  leadEmail: string,
  propertyId: number,
  propertyTitle: string
): Promise<void> {
  await sendN8NWebhook({
    event: "lead_updated",
    data: {
      leadId,
      leadEmail,
      propertyId,
      propertyTitle,
      action: "send_property_recommendation",
    },
  });
}

// ============================================
// FUNÇÕES DE CONFIGURAÇÃO
// ============================================

/**
 * Retorna a configuração de automações disponíveis
 */
export function getAvailableAutomations(): N8NAutomation[] {
  return [
    {
      name: "Follow-up Automático",
      trigger: "lead_stage_change",
      actions: [
        {
          type: "send_email",
          config: {
            template: "follow_up",
            delay: "1d",
          },
        },
        {
          type: "send_whatsapp",
          config: {
            template: "follow_up_message",
          },
        },
      ],
      enabled: true,
    },
    {
      name: "Análise de Perfil",
      trigger: "lead_interaction",
      actions: [
        {
          type: "analyze_interactions",
          config: {
            minInteractions: 3,
          },
        },
        {
          type: "update_lead_score",
          config: {
            algorithm: "ml_model",
          },
        },
      ],
      enabled: true,
    },
    {
      name: "Notificação de Pagamento Atrasado",
      trigger: "payment_overdue",
      actions: [
        {
          type: "send_email",
          config: {
            template: "overdue_payment",
          },
        },
        {
          type: "send_sms",
          config: {
            template: "overdue_payment_sms",
          },
        },
      ],
      enabled: true,
    },
    {
      name: "Geração de Boleto",
      trigger: "payment_created",
      actions: [
        {
          type: "generate_boleto",
          config: {
            bank: "bb",
          },
        },
        {
          type: "send_email",
          config: {
            template: "boleto_payment",
          },
        },
      ],
      enabled: true,
    },
    {
      name: "Geração de PIX",
      trigger: "payment_created",
      actions: [
        {
          type: "generate_pix",
          config: {
            type: "static",
          },
        },
        {
          type: "send_whatsapp",
          config: {
            template: "pix_payment",
          },
        },
      ],
      enabled: true,
    },
  ];
}

/**
 * Retorna o status da integração com N8N
 */
export async function checkN8NStatus(): Promise<{
  connected: boolean;
  webhookUrl: string;
  lastCheck: string;
}> {
  try {
    const response = await fetch(`${N8N_WEBHOOK_URL}/health`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${N8N_API_KEY}`,
      },
    });

    return {
      connected: response.ok,
      webhookUrl: N8N_WEBHOOK_URL,
      lastCheck: new Date().toISOString(),
    };
  } catch (error) {
    return {
      connected: false,
      webhookUrl: N8N_WEBHOOK_URL,
      lastCheck: new Date().toISOString(),
    };
  }
}
