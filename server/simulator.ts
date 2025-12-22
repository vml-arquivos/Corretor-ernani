// server/simulator.ts

/**
 * Módulo de Lógica de Negócios para o Simulador de Financiamento
 * Implementa os cálculos para as tabelas SAC e PRICE.
 */

import { z } from "zod";

// Schema de entrada para o cálculo
export const SimulatorInputSchema = z.object({
  loanAmount: z.number().min(1000, "O valor do empréstimo deve ser maior que R$ 1.000,00"),
  annualRate: z.number().min(0.01, "A taxa anual deve ser maior que 0%"),
  termInMonths: z.number().min(12, "O prazo deve ser de no mínimo 12 meses"),
  rateType: z.enum(["sac", "price"]),
});

export type SimulatorInput = z.infer<typeof SimulatorInputSchema>;

// Schema de saída para o resultado do cálculo
export type AmortizationRow = {
  month: number;
  beginningBalance: number;
  interest: number;
  amortization: number;
  installment: number;
  endingBalance: number;
};

export type SimulatorResult = {
  rateType: "sac" | "price";
  monthlyRate: number;
  totalInterest: number;
  totalCost: number;
  amortizationTable: AmortizationRow[];
};

/**
 * Converte taxa anual para mensal.
 * @param annualRate Taxa anual em porcentagem (ex: 8.5 para 8.5%)
 * @returns Taxa mensal em decimal (ex: 0.00708333)
 */
const convertAnnualToMonthlyRate = (annualRate: number): number => {
  // Taxa anual em decimal
  const rateDecimal = annualRate / 100;
  // Taxa mensal (juros compostos)
  return Math.pow(1 + rateDecimal, 1 / 12) - 1;
};

/**
 * Arredonda um número para duas casas decimais.
 * @param num Número a ser arredondado
 * @returns Número arredondado
 */
const roundToTwoDecimals = (num: number): number => {
  return Math.round(num * 100) / 100;
};

/**
 * Calcula a amortização pela Tabela SAC (Sistema de Amortização Constante).
 * @param loanAmount Valor do empréstimo
 * @param monthlyRate Taxa de juros mensal em decimal
 * @param termInMonths Prazo em meses
 * @returns Resultado da simulação
 */
const calculateSAC = (
  loanAmount: number,
  monthlyRate: number,
  termInMonths: number
): SimulatorResult => {
  const amortizationConstant = loanAmount / termInMonths;
  let remainingBalance = loanAmount;
  let totalInterest = 0;
  const amortizationTable: AmortizationRow[] = [];

  for (let month = 1; month <= termInMonths; month++) {
    const beginningBalance = remainingBalance;
    const interest = beginningBalance * monthlyRate;
    const amortization = amortizationConstant;
    const installment = interest + amortization;
    const endingBalance = beginningBalance - amortization;

    totalInterest += interest;

    amortizationTable.push({
      month,
      beginningBalance: roundToTwoDecimals(beginningBalance),
      interest: roundToTwoDecimals(interest),
      amortization: roundToTwoDecimals(amortization),
      installment: roundToTwoDecimals(installment),
      endingBalance: roundToTwoDecimals(endingBalance < 0.01 ? 0 : endingBalance), // Evita valores negativos por arredondamento
    });

    remainingBalance = endingBalance;
  }

  const totalCost = loanAmount + totalInterest;

  return {
    rateType: "sac",
    monthlyRate: roundToTwoDecimals(monthlyRate * 100),
    totalInterest: roundToTwoDecimals(totalInterest),
    totalCost: roundToTwoDecimals(totalCost),
    amortizationTable,
  };
};

/**
 * Calcula a amortização pela Tabela PRICE (Sistema Francês de Amortização).
 * @param loanAmount Valor do empréstimo
 * @param monthlyRate Taxa de juros mensal em decimal
 * @param termInMonths Prazo em meses
 * @returns Resultado da simulação
 */
const calculatePRICE = (
  loanAmount: number,
  monthlyRate: number,
  termInMonths: number
): SimulatorResult => {
  // Cálculo da parcela constante (PMT)
  const installment =
    loanAmount *
    (monthlyRate / (1 - Math.pow(1 + monthlyRate, -termInMonths)));

  let remainingBalance = loanAmount;
  let totalInterest = 0;
  const amortizationTable: AmortizationRow[] = [];

  for (let month = 1; month <= termInMonths; month++) {
    const beginningBalance = remainingBalance;
    const interest = beginningBalance * monthlyRate;
    const amortization = installment - interest;
    const endingBalance = beginningBalance - amortization;

    totalInterest += interest;

    amortizationTable.push({
      month,
      beginningBalance: roundToTwoDecimals(beginningBalance),
      interest: roundToTwoDecimals(interest),
      amortization: roundToTwoDecimals(amortization),
      installment: roundToTwoDecimals(installment),
      endingBalance: roundToTwoDecimals(endingBalance < 0.01 ? 0 : endingBalance),
    });

    remainingBalance = endingBalance;
  }

  const totalCost = loanAmount + totalInterest;

  return {
    rateType: "price",
    monthlyRate: roundToTwoDecimals(monthlyRate * 100),
    totalInterest: roundToTwoDecimals(totalInterest),
    totalCost: roundToTwoDecimals(totalCost),
    amortizationTable,
  };
};

/**
 * Função principal para simulação.
 * @param input Dados de entrada
 * @returns Resultado da simulação
 */
export const simulateFinancing = (input: SimulatorInput): SimulatorResult => {
  const { loanAmount, annualRate, termInMonths, rateType } = input;

  // 1. Converter taxa anual para mensal
  const monthlyRate = convertAnnualToMonthlyRate(annualRate);

  // 2. Calcular
  if (rateType === "sac") {
    return calculateSAC(loanAmount, monthlyRate, termInMonths);
  } else {
    return calculatePRICE(loanAmount, monthlyRate, termInMonths);
  }
};
