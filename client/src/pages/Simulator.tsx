import { useState, useMemo } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useMutation } from "@tanstack/react-query";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import { Separator } from "../components/ui/separator";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../components/ui/table";
import { trpc } from "../lib/trpc";
import { Loader2 } from "lucide-react";

// --- Schemas ---

// Schema de entrada para o cálculo (deve ser o mesmo do backend)
const SimulatorInputSchema = z.object({
  loanAmount: z.coerce.number().min(1000, "Valor mínimo de R$ 1.000,00"),
  annualRate: z.coerce.number().min(0.01, "Taxa anual deve ser maior que 0%"),
  termInMonths: z.coerce.number().min(12, "Prazo mínimo de 12 meses"),
  rateType: z.enum(["sac", "price"]),
});

// Schema para o formulário completo (incluindo dados do lead)
const FullFormSchema = SimulatorInputSchema.extend({
  name: z.string().min(2, "Nome é obrigatório"),
  phone: z.string().min(8, "Telefone é obrigatório"),
  email: z.string().email("E-mail inválido").optional().or(z.literal("")),
  // Dados do imóvel para o lead
  propertyValue: z.coerce.number().min(10000, "Valor do imóvel é obrigatório"),
  downPayment: z.coerce.number().min(0, "Entrada mínima de R$ 0,00"),
});

type FullFormInput = z.infer<typeof FullFormSchema>;

// --- Tipos de Resultado (Simplificados) ---
type AmortizationRow = {
  month: number;
  beginningBalance: number;
  interest: number;
  amortization: number;
  installment: number;
  endingBalance: number;
};

type SimulatorResult = {
  rateType: "sac" | "price";
  monthlyRate: number;
  totalInterest: number;
  totalCost: number;
  amortizationTable: AmortizationRow[];
};

// --- Componente de Tabela de Amortização ---
const AmortizationTable = ({ table }: { table: AmortizationRow[] }) => {
  const formatCurrency = (value: number) =>
    new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);

  return (
    <div className="overflow-x-auto max-h-[400px]">
      <Table className="min-w-full">
        <TableHeader className="sticky top-0 bg-background">
          <TableRow>
            <TableHead>Mês</TableHead>
            <TableHead>Saldo Inicial</TableHead>
            <TableHead>Juros</TableHead>
            <TableHead>Amortização</TableHead>
            <TableHead>Parcela</TableHead>
            <TableHead>Saldo Final</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {table.slice(0, 12).map((row) => ( // Mostra apenas os primeiros 12 meses para não sobrecarregar
            <TableRow key={row.month}>
              <TableCell>{row.month}</TableCell>
              <TableCell>{formatCurrency(row.beginningBalance)}</TableCell>
              <TableCell>{formatCurrency(row.interest)}</TableCell>
              <TableCell>{formatCurrency(row.amortization)}</TableCell>
              <TableCell className="font-medium">{formatCurrency(row.installment)}</TableCell>
              <TableCell>{formatCurrency(row.endingBalance)}</TableCell>
            </TableRow>
          ))}
          {table.length > 12 && (
            <TableRow>
              <TableCell colSpan={6} className="text-center text-muted-foreground">
                ... Tabela completa com {table.length} meses (apenas os 12 primeiros exibidos)
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
};

// --- Componente Principal ---
export const SimulatorPage = () => {
  const trpcClient = trpc.useUtils();
  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<FullFormInput>({
    resolver: zodResolver(FullFormSchema),
    defaultValues: {
      loanAmount: 300000,
      annualRate: 8.5,
      termInMonths: 360,
      rateType: "price",
      propertyValue: 400000,
      downPayment: 100000,
      name: "",
      phone: "",
      email: "",
    },
  });

  const [result, setResult] = useState<SimulatorResult | null>(null);

  // Watch para calcular o valor do empréstimo automaticamente
  const propertyValue = watch("propertyValue");
  const downPayment = watch("downPayment");

  useMemo(() => {
    const calculatedLoanAmount = propertyValue - downPayment;
    setValue("loanAmount", calculatedLoanAmount > 0 ? calculatedLoanAmount : 0);
  }, [propertyValue, downPayment, setValue]);

  const loanAmount = watch("loanAmount");

  // Mutação para simular
  const simulateMutation = trpc.simulator.simulate.useMutation({
    onSuccess: (data) => {
      setResult(data as SimulatorResult);
    },
    onError: (error: any) => {
      console.error("Erro na simulação:", error);
      alert("Erro ao simular financiamento: " + error.message);
    },
  });

  // Mutação para criar lead
  const createLeadMutation = trpc.leads.create.useMutation({
    onSuccess: () => {
      alert("Seu contato foi salvo! Em breve um especialista entrará em contato.");
    },
    onError: (error: any) => {
      console.error("Erro ao salvar lead:", error);
      alert("Erro ao salvar seu contato. Por favor, tente novamente.");
    },
  });

  const onSubmit = (data: FullFormInput) => {
    // 1. Simular
    simulateMutation.mutate({
      loanAmount: data.loanAmount,
      annualRate: data.annualRate,
      termInMonths: data.termInMonths,
      rateType: data.rateType,
    });

    // 2. Criar Lead
    const notes = `Simulação de Financiamento:
- Valor do Imóvel: R$ ${data.propertyValue.toFixed(2)}
- Entrada: R$ ${data.downPayment.toFixed(2)}
- Valor Financiado: R$ ${data.loanAmount.toFixed(2)}
- Taxa Anual: ${data.annualRate}%
- Prazo: ${data.termInMonths} meses
- Sistema: ${data.rateType.toUpperCase()}
${result ? `- Primeira Parcela: R$ ${result.amortizationTable[0].installment.toFixed(2)}` : ''}
`;

    createLeadMutation.mutate({
      name: data.name,
      phone: data.phone,
      email: data.email || undefined,
      source: "site",
      notes: notes,
    });
  };

  return (
    <div className="container mx-auto py-12">
      <Card className="max-w-4xl mx-auto">
        <CardHeader>
          <CardTitle className="text-3xl font-bold text-primary">Simulador de Financiamento Imobiliário</CardTitle>
          <CardDescription>
            Calcule as parcelas do seu financiamento nas modalidades SAC e PRICE.
            Preencha seus dados para que um especialista entre em contato com as melhores taxas do dia.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="grid gap-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Dados do Imóvel */}
              <div className="space-y-2">
                <Label htmlFor="propertyValue">Valor do Imóvel (R$)</Label>
                <Input
                  id="propertyValue"
                  type="number"
                  step="any"
                  {...register("propertyValue")}
                />
                {errors.propertyValue && (
                  <p className="text-sm text-red-500">{errors.propertyValue.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="downPayment">Valor da Entrada (R$)</Label>
                <Input
                  id="downPayment"
                  type="number"
                  step="any"
                  {...register("downPayment")}
                />
                {errors.downPayment && (
                  <p className="text-sm text-red-500">{errors.downPayment.message}</p>
                )}
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="loanAmount">Valor Financiado (R$)</Label>
              <Input
                id="loanAmount"
                type="number"
                step="any"
                readOnly
                value={loanAmount.toFixed(2)}
                className="bg-gray-100 font-bold"
              />
              {errors.loanAmount && (
                <p className="text-sm text-red-500">{errors.loanAmount.message}</p>
              )}
            </div>

            <Separator />

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Taxa Anual */}
              <div className="space-y-2">
                <Label htmlFor="annualRate">Taxa de Juros Anual (%)</Label>
                <Input
                  id="annualRate"
                  type="number"
                  step="any"
                  {...register("annualRate")}
                />
                {errors.annualRate && (
                  <p className="text-sm text-red-500">{errors.annualRate.message}</p>
                )}
              </div>

              {/* Prazo */}
              <div className="space-y-2">
                <Label htmlFor="termInMonths">Prazo (Meses)</Label>
                <Input
                  id="termInMonths"
                  type="number"
                  step="1"
                  {...register("termInMonths")}
                />
                {errors.termInMonths && (
                  <p className="text-sm text-red-500">{errors.termInMonths.message}</p>
                )}
              </div>

              {/* Tipo de Tabela */}
              <div className="space-y-2">
                <Label htmlFor="rateType">Sistema de Amortização</Label>
                <Select
                  onValueChange={(value) => setValue("rateType", value as "sac" | "price")}
                  defaultValue={watch("rateType")}
                >
                  <SelectTrigger id="rateType">
                    <SelectValue placeholder="Selecione o sistema" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="price">PRICE (Parcelas Constantes)</SelectItem>
                    <SelectItem value="sac">SAC (Amortização Constante)</SelectItem>
                  </SelectContent>
                </Select>
                {errors.rateType && (
                  <p className="text-sm text-red-500">{errors.rateType.message}</p>
                )}
              </div>
            </div>

            <Separator />

            <h3 className="text-xl font-semibold">Seus Dados</h3>
            <p className="text-sm text-muted-foreground">
              Preencha para receber as melhores propostas de financiamento.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Nome Completo</Label>
                <Input id="name" {...register("name")} />
                {errors.name && (
                  <p className="text-sm text-red-500">{errors.name.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="phone">Telefone/WhatsApp</Label>
                <Input id="phone" {...register("phone")} />
                {errors.phone && (
                  <p className="text-sm text-red-500">{errors.phone.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="email">E-mail (Opcional)</Label>
                <Input id="email" type="email" {...register("email")} />
                {errors.email && (
                  <p className="text-sm text-red-500">{errors.email.message}</p>
                )}
              </div>
            </div>

            <Button
              type="submit"
              className="w-full"
              disabled={simulateMutation.isPending || createLeadMutation.isPending}
            >
              {(simulateMutation.isPending || createLeadMutation.isPending) && (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              )}
              Simular e Enviar Proposta
            </Button>
          </form>

          {/* Resultados da Simulação */}
          {result && (
            <div className="mt-8 space-y-6">
              <h3 className="text-2xl font-bold text-green-600">Resultado da Simulação ({result.rateType.toUpperCase()})</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card className="p-4">
                  <p className="text-sm text-muted-foreground">Primeira Parcela</p>
                  <p className="text-xl font-bold text-primary">
                    {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(result.amortizationTable[0].installment)}
                  </p>
                </Card>
                <Card className="p-4">
                  <p className="text-sm text-muted-foreground">Total de Juros</p>
                  <p className="text-xl font-bold text-primary">
                    {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(result.totalInterest)}
                  </p>
                </Card>
                <Card className="p-4">
                  <p className="text-sm text-muted-foreground">Custo Total (Empréstimo + Juros)</p>
                  <p className="text-xl font-bold text-primary">
                    {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(result.totalCost)}
                  </p>
                </Card>
              </div>
              <h4 className="text-xl font-semibold mt-6">Tabela de Amortização (Primeiros 12 Meses)</h4>
              <AmortizationTable table={result.amortizationTable} />
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default SimulatorPage;
