/**
 * Helpers de banco de dados para CRM
 * Funções para gerenciar pipeline de vendas, tarefas e qualificação de leads
 */

import { db } from "./db";
import { salesPipeline, tasks, leads } from "../drizzle/schema";
import { eq, and, desc } from "drizzle-orm";

// ============================================
// PIPELINE DE VENDAS
// ============================================

export async function createSalesPipeline(data: {
  leadId: number;
  propertyId?: number;
  stage?: string;
  probability?: number;
  estimatedValue?: number;
  expectedCloseDate?: Date;
  notes?: string;
}) {
  try {
    const result = await db.insert(salesPipeline).values({
      leadId: data.leadId,
      propertyId: data.propertyId,
      stage: data.stage || "novo",
      probability: data.probability || 0,
      estimatedValue: data.estimatedValue,
      expectedCloseDate: data.expectedCloseDate,
      notes: data.notes,
    }).returning();
    return result[0];
  } catch (error) {
    console.error("Erro ao criar pipeline:", error);
    return null;
  }
}

export async function updateSalesPipeline(id: number, data: Partial<{
  stage: string;
  probability: number;
  estimatedValue: number;
  expectedCloseDate: Date;
  closedAt: Date;
  notes: string;
}>) {
  try {
    const result = await db.update(salesPipeline)
      .set(data)
      .where(eq(salesPipeline.id, id))
      .returning();
    return result[0];
  } catch (error) {
    console.error("Erro ao atualizar pipeline:", error);
    return null;
  }
}

export async function getSalesPipelineByLeadId(leadId: number) {
  try {
    return await db.select().from(salesPipeline)
      .where(eq(salesPipeline.leadId, leadId));
  } catch (error) {
    console.error("Erro ao buscar pipeline:", error);
    return [];
  }
}

export async function getAllSalesPipelines() {
  try {
    return await db.select().from(salesPipeline)
      .orderBy(desc(salesPipeline.createdAt));
  } catch (error) {
    console.error("Erro ao buscar pipelines:", error);
    return [];
  }
}

export async function getSalesPipelinesByStage(stage: string) {
  try {
    return await db.select().from(salesPipeline)
      .where(eq(salesPipeline.stage, stage))
      .orderBy(desc(salesPipeline.probability));
  } catch (error) {
    console.error("Erro ao buscar pipelines por estágio:", error);
    return [];
  }
}

// ============================================
// TAREFAS/FOLLOW-UP
// ============================================

export async function createTask(data: {
  leadId: number;
  assignedTo?: number;
  title: string;
  description?: string;
  type: string;
  priority?: string;
  dueDate?: Date;
}) {
  try {
    const result = await db.insert(tasks).values({
      leadId: data.leadId,
      assignedTo: data.assignedTo,
      title: data.title,
      description: data.description,
      type: data.type,
      priority: data.priority || "media",
      status: "pendente",
      dueDate: data.dueDate,
    }).returning();
    return result[0];
  } catch (error) {
    console.error("Erro ao criar tarefa:", error);
    return null;
  }
}

export async function updateTask(id: number, data: Partial<{
  status: string;
  priority: string;
  dueDate: Date;
  completedAt: Date;
  title: string;
  description: string;
}>) {
  try {
    const result = await db.update(tasks)
      .set(data)
      .where(eq(tasks.id, id))
      .returning();
    return result[0];
  } catch (error) {
    console.error("Erro ao atualizar tarefa:", error);
    return null;
  }
}

export async function getTasksByLeadId(leadId: number) {
  try {
    return await db.select().from(tasks)
      .where(eq(tasks.leadId, leadId))
      .orderBy(desc(tasks.dueDate));
  } catch (error) {
    console.error("Erro ao buscar tarefas:", error);
    return [];
  }
}

export async function getTasksByUserId(userId: number) {
  try {
    return await db.select().from(tasks)
      .where(eq(tasks.assignedTo, userId))
      .orderBy(desc(tasks.dueDate));
  } catch (error) {
    console.error("Erro ao buscar tarefas do usuário:", error);
    return [];
  }
}

export async function getPendingTasks() {
  try {
    return await db.select().from(tasks)
      .where(eq(tasks.status, "pendente"))
      .orderBy(desc(tasks.priority));
  } catch (error) {
    console.error("Erro ao buscar tarefas pendentes:", error);
    return [];
  }
}

export async function deleteTask(id: number) {
  try {
    await db.delete(tasks).where(eq(tasks.id, id));
    return true;
  } catch (error) {
    console.error("Erro ao deletar tarefa:", error);
    return false;
  }
}

// ============================================
// ANÁLISE E QUALIFICAÇÃO DE LEADS
// ============================================

export async function getLeadQualificationMetrics() {
  try {
    const allLeads = await db.select().from(leads);
    
    const metrics = {
      total: allLeads.length,
      quente: allLeads.filter(l => l.qualification === "quente").length,
      morno: allLeads.filter(l => l.qualification === "morno").length,
      frio: allLeads.filter(l => l.qualification === "frio").length,
      naoQualificado: allLeads.filter(l => l.qualification === "nao_qualificado").length,
    };
    
    return metrics;
  } catch (error) {
    console.error("Erro ao buscar métricas de qualificação:", error);
    return null;
  }
}

export async function getLeadsByQualification(qualification: string) {
  try {
    return await db.select().from(leads)
      .where(eq(leads.qualification, qualification));
  } catch (error) {
    console.error("Erro ao buscar leads por qualificação:", error);
    return [];
  }
}

export async function getLeadsByStage(stage: string) {
  try {
    return await db.select().from(leads)
      .where(eq(leads.stage, stage));
  } catch (error) {
    console.error("Erro ao buscar leads por estágio:", error);
    return [];
  }
}

export async function getLeadsByPriority(priority: string) {
  try {
    return await db.select().from(leads)
      .where(eq(leads.priority, priority))
      .orderBy(desc(leads.score));
  } catch (error) {
    console.error("Erro ao buscar leads por prioridade:", error);
    return [];
  }
}

export async function getHighValueLeads(minBudget: number) {
  try {
    const allLeads = await db.select().from(leads);
    return allLeads.filter(l => 
      (l.budgetMax && l.budgetMax >= minBudget) || 
      (l.budgetMin && l.budgetMin >= minBudget)
    );
  } catch (error) {
    console.error("Erro ao buscar leads de alto valor:", error);
    return [];
  }
}
