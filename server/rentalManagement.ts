// server/rentalManagement.ts

/**
 * Módulo de Lógica de Negócios para Gestão de Aluguel
 * Implementa cálculos de comissões, despesas, pagamentos e relatórios
 */

import { z } from "zod";

// ============================================
// SCHEMAS
// ============================================

export const CreateRentalSchema = z.object({
  propertyId: z.number().min(1),
  tenantId: z.number().min(1),
  ownerId: z.number().min(1),
  monthlyRent: z.number().min(0),
  commissionPercentage: z.number().min(0).max(100).optional().default(5),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});

export const CreatePaymentSchema = z.object({
  rentalId: z.number().min(1),
  tenantId: z.number().min(1),
  amount: z.number().min(0),
  dueDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  paymentMethod: z.enum(["boleto", "pix", "transferencia", "dinheiro", "outro"]),
  paymentReference: z.string().optional(),
});

export const CreateExpenseSchema = z.object({
  rentalId: z.number().min(1),
  propertyId: z.number().min(1),
  expenseType: z.enum([
    "manutencao",
    "limpeza",
    "reparos",
    "seguro",
    "iptu",
    "condominio",
    "agua",
    "luz",
    "internet",
    "outro",
  ]),
  amount: z.number().min(0),
  description: z.string().optional(),
  expenseDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

// ============================================
// TIPOS
// ============================================

export type RentalSummary = {
  rentalId: number;
  propertyId: number;
  tenantId: number;
  ownerId: number;
  monthlyRent: number;
  commissionPercentage: number;
  commissionAmount: number;
  totalPaid: number;
  totalExpenses: number;
  totalDue: number;
  netIncome: number;
  status: "ativo" | "finalizado" | "cancelado" | "suspenso";
};

export type PaymentReport = {
  period: string;
  totalExpected: number;
  totalReceived: number;
  totalPending: number;
  totalOverdue: number;
  paymentRate: number; // percentual
};

export type ExpenseReport = {
  period: string;
  totalExpenses: number;
  byType: Record<string, number>;
};

export type FinancialSummary = {
  totalIncome: number;
  totalExpenses: number;
  totalCommissions: number;
  netProfit: number;
  activeRentals: number;
  pendingPayments: number;
};

// ============================================
// FUNÇÕES UTILITÁRIAS
// ============================================

const roundToTwoDecimals = (num: number): number => {
  return Math.round(num * 100) / 100;
};

const calculateCommission = (
  monthlyRent: number,
  commissionPercentage: number
): number => {
  return roundToTwoDecimals((monthlyRent * commissionPercentage) / 100);
};

const getMonthsBetweenDates = (startDate: string, endDate: string): number => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  const months =
    (end.getFullYear() - start.getFullYear()) * 12 +
    (end.getMonth() - start.getMonth());
  return Math.max(0, months + 1);
};

// ============================================
// FUNÇÕES DE CÁLCULO
// ============================================

/**
 * Calcula o resumo financeiro de um aluguel
 */
export const calculateRentalSummary = (
  monthlyRent: number,
  commissionPercentage: number,
  totalPaid: number,
  totalExpenses: number
): RentalSummary => {
  const commissionAmount = calculateCommission(monthlyRent, commissionPercentage);
  const totalDue = monthlyRent - totalPaid;
  const netIncome = totalPaid - totalExpenses - commissionAmount;

  return {
    rentalId: 0, // Será preenchido pelo caller
    propertyId: 0,
    tenantId: 0,
    ownerId: 0,
    monthlyRent,
    commissionPercentage,
    commissionAmount,
    totalPaid,
    totalExpenses,
    totalDue,
    netIncome,
    status: "ativo",
  };
};

/**
 * Gera relatório de pagamentos para um período
 */
export const generatePaymentReport = (
  payments: Array<{
    amount: number;
    dueDate: string;
    status: "pendente" | "pago" | "atrasado" | "cancelado";
  }>,
  period: string
): PaymentReport => {
  const totalExpected = payments.reduce((sum, p) => sum + p.amount, 0);
  const totalReceived = payments
    .filter((p) => p.status === "pago")
    .reduce((sum, p) => sum + p.amount, 0);
  const totalPending = payments
    .filter((p) => p.status === "pendente")
    .reduce((sum, p) => sum + p.amount, 0);
  const totalOverdue = payments
    .filter((p) => p.status === "atrasado")
    .reduce((sum, p) => sum + p.amount, 0);

  const paymentRate =
    totalExpected > 0 ? (totalReceived / totalExpected) * 100 : 0;

  return {
    period,
    totalExpected: roundToTwoDecimals(totalExpected),
    totalReceived: roundToTwoDecimals(totalReceived),
    totalPending: roundToTwoDecimals(totalPending),
    totalOverdue: roundToTwoDecimals(totalOverdue),
    paymentRate: roundToTwoDecimals(paymentRate),
  };
};

/**
 * Gera relatório de despesas para um período
 */
export const generateExpenseReport = (
  expenses: Array<{
    expenseType: string;
    amount: number;
  }>,
  period: string
): ExpenseReport => {
  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);
  const byType: Record<string, number> = {};

  expenses.forEach((expense) => {
    if (!byType[expense.expenseType]) {
      byType[expense.expenseType] = 0;
    }
    byType[expense.expenseType] += expense.amount;
  });

  // Arredondar todos os valores
  Object.keys(byType).forEach((key) => {
    byType[key] = roundToTwoDecimals(byType[key]);
  });

  return {
    period,
    totalExpenses: roundToTwoDecimals(totalExpenses),
    byType,
  };
};

/**
 * Gera resumo financeiro geral
 */
export const generateFinancialSummary = (
  rentals: Array<{
    id: number;
    monthlyRent: number;
    commissionPercentage: number;
    status: string;
  }>,
  payments: Array<{
    amount: number;
    status: string;
  }>,
  expenses: Array<{
    amount: number;
  }>,
  commissions: Array<{
    amount: number;
  }>
): FinancialSummary => {
  const totalIncome = payments
    .filter((p) => p.status === "pago")
    .reduce((sum, p) => sum + p.amount, 0);

  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);

  const totalCommissions = commissions.reduce((sum, c) => sum + c.amount, 0);

  const netProfit = totalIncome - totalExpenses - totalCommissions;

  const activeRentals = rentals.filter((r) => r.status === "ativo").length;

  const pendingPayments = payments.filter(
    (p) => p.status === "pendente" || p.status === "atrasado"
  ).length;

  return {
    totalIncome: roundToTwoDecimals(totalIncome),
    totalExpenses: roundToTwoDecimals(totalExpenses),
    totalCommissions: roundToTwoDecimals(totalCommissions),
    netProfit: roundToTwoDecimals(netProfit),
    activeRentals,
    pendingPayments,
  };
};

/**
 * Gera número de boleto (simulado)
 */
export const generateBoletoNumber = (rentalId: number, month: number): string => {
  const timestamp = Date.now().toString().slice(-6);
  return `${rentalId.toString().padStart(6, "0")}.${month.toString().padStart(2, "0")}.${timestamp}`;
};

/**
 * Gera QR Code PIX (estrutura simulada)
 */
export const generatePixQrCode = (
  amount: number,
  recipientKey: string,
  description: string
): string => {
  // Simulação: em produção, usar biblioteca de geração de QR Code PIX
  return `pix:${recipientKey}|amount=${amount}|desc=${description}`;
};
