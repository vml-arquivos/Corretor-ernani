import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from "recharts";
import { Download, Filter } from "lucide-react";

const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6"];

export default function RentalReports() {
  const [reportType, setReportType] = useState("payments");
  const [period, setPeriod] = useState("current_month");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  // Dados simulados para demonstração
  const paymentData = [
    { month: "Janeiro", esperado: 5000, recebido: 4800, pendente: 200 },
    { month: "Fevereiro", esperado: 5000, recebido: 5000, pendente: 0 },
    { month: "Março", esperado: 5000, recebido: 4500, pendente: 500 },
    { month: "Abril", esperado: 5000, recebido: 5000, pendente: 0 },
    { month: "Maio", esperado: 5000, recebido: 4900, pendente: 100 },
  ];

  const expenseData = [
    { name: "Manutenção", value: 2500 },
    { name: "Limpeza", value: 800 },
    { name: "Reparos", value: 1200 },
    { name: "Condomínio", value: 3000 },
    { name: "Outros", value: 500 },
  ];

  const paymentsByMethod = [
    { method: "PIX", count: 15, amount: 7500 },
    { method: "Boleto", count: 8, amount: 4000 },
    { method: "Transferência", count: 5, amount: 2500 },
    { method: "Dinheiro", count: 2, amount: 1000 },
  ];

  const clientPayments = [
    { id: 1, client: "João Silva", property: "Apto 101", rent: 2000, paid: 2000, status: "pago", date: "2025-01-15" },
    { id: 2, client: "Maria Santos", property: "Apto 202", rent: 2500, paid: 2500, status: "pago", date: "2025-01-18" },
    { id: 3, client: "Pedro Oliveira", property: "Casa 45", rent: 3000, paid: 0, status: "atrasado", date: "2025-01-10" },
    { id: 4, client: "Ana Costa", property: "Apto 305", rent: 2000, paid: 2000, status: "pago", date: "2025-01-20" },
  ];

  const propertyPerformance = [
    { property: "Apto 101", rent: 2000, expenses: 500, commission: 100, net: 1400 },
    { property: "Apto 202", rent: 2500, expenses: 600, commission: 125, net: 1775 },
    { property: "Casa 45", rent: 3000, expenses: 800, commission: 150, net: 2050 },
    { property: "Apto 305", rent: 2000, expenses: 450, commission: 100, net: 1450 },
  ];

  const financialSummary = {
    totalIncome: 18500,
    totalExpenses: 4200,
    totalCommissions: 725,
    netProfit: 13575,
    activeRentals: 4,
    pendingPayments: 1,
  };

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(value);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Relatórios de Aluguel</h1>
        <p className="text-muted-foreground">Análise financeira e desempenho dos imóveis alugados</p>
      </div>

      {/* Filtros */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Filter className="h-5 w-5" />
            Filtros
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="space-y-2">
              <Label>Tipo de Relatório</Label>
              <Select value={reportType} onValueChange={setReportType}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="payments">Pagamentos</SelectItem>
                  <SelectItem value="expenses">Despesas</SelectItem>
                  <SelectItem value="properties">Imóveis</SelectItem>
                  <SelectItem value="financial">Financeiro</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Período</Label>
              <Select value={period} onValueChange={setPeriod}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="current_month">Mês Atual</SelectItem>
                  <SelectItem value="last_month">Mês Anterior</SelectItem>
                  <SelectItem value="last_3_months">Últimos 3 Meses</SelectItem>
                  <SelectItem value="last_6_months">Últimos 6 Meses</SelectItem>
                  <SelectItem value="custom">Personalizado</SelectItem>
                </SelectContent>
              </Select>
            </div>
            {period === "custom" && (
              <>
                <div className="space-y-2">
                  <Label>Data Inicial</Label>
                  <Input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} />
                </div>
                <div className="space-y-2">
                  <Label>Data Final</Label>
                  <Input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} />
                </div>
              </>
            )}
            <div className="flex items-end">
              <Button className="w-full">
                <Download className="h-4 w-4 mr-2" />
                Exportar PDF
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Resumo Financeiro */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Receita Total</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(financialSummary.totalIncome)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Despesas</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{formatCurrency(financialSummary.totalExpenses)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Comissões</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{formatCurrency(financialSummary.totalCommissions)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Lucro Líquido</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{formatCurrency(financialSummary.netProfit)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Pendências</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{financialSummary.pendingPayments}</div>
          </CardContent>
        </Card>
      </div>

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Gráfico de Pagamentos */}
        <Card>
          <CardHeader>
            <CardTitle>Pagamentos por Mês</CardTitle>
            <CardDescription>Comparação entre esperado, recebido e pendente</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={paymentData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip formatter={(value) => formatCurrency(value)} />
                <Legend />
                <Bar dataKey="esperado" fill="#3b82f6" name="Esperado" />
                <Bar dataKey="recebido" fill="#10b981" name="Recebido" />
                <Bar dataKey="pendente" fill="#f59e0b" name="Pendente" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Gráfico de Despesas */}
        <Card>
          <CardHeader>
            <CardTitle>Despesas por Tipo</CardTitle>
            <CardDescription>Distribuição das despesas operacionais</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={expenseData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, value }) => `${name}: ${formatCurrency(value)}`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {expenseData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => formatCurrency(value)} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Tabelas */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pagamentos por Cliente */}
        <Card>
          <CardHeader>
            <CardTitle>Pagamentos por Cliente</CardTitle>
            <CardDescription>Status dos pagamentos de aluguel</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Cliente</TableHead>
                    <TableHead>Imóvel</TableHead>
                    <TableHead>Aluguel</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {clientPayments.map((payment) => (
                    <TableRow key={payment.id}>
                      <TableCell className="font-medium">{payment.client}</TableCell>
                      <TableCell>{payment.property}</TableCell>
                      <TableCell>{formatCurrency(payment.rent)}</TableCell>
                      <TableCell>
                        <span
                          className={`px-2 py-1 rounded-full text-xs font-medium ${
                            payment.status === "pago"
                              ? "bg-green-100 text-green-800"
                              : payment.status === "atrasado"
                              ? "bg-red-100 text-red-800"
                              : "bg-yellow-100 text-yellow-800"
                          }`}
                        >
                          {payment.status.toUpperCase()}
                        </span>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Desempenho por Imóvel */}
        <Card>
          <CardHeader>
            <CardTitle>Desempenho por Imóvel</CardTitle>
            <CardDescription>Receita, despesas e lucro líquido</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Imóvel</TableHead>
                    <TableHead>Aluguel</TableHead>
                    <TableHead>Lucro</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {propertyPerformance.map((prop, idx) => (
                    <TableRow key={idx}>
                      <TableCell className="font-medium">{prop.property}</TableCell>
                      <TableCell>{formatCurrency(prop.rent)}</TableCell>
                      <TableCell className="text-green-600 font-medium">{formatCurrency(prop.net)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Métodos de Pagamento */}
      <Card>
        <CardHeader>
          <CardTitle>Métodos de Pagamento</CardTitle>
          <CardDescription>Distribuição de pagamentos por método</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Método</TableHead>
                  <TableHead>Quantidade</TableHead>
                  <TableHead>Valor Total</TableHead>
                  <TableHead>Percentual</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paymentsByMethod.map((method, idx) => {
                  const total = paymentsByMethod.reduce((sum, m) => sum + m.amount, 0);
                  const percentage = ((method.amount / total) * 100).toFixed(1);
                  return (
                    <TableRow key={idx}>
                      <TableCell className="font-medium">{method.method}</TableCell>
                      <TableCell>{method.count}</TableCell>
                      <TableCell>{formatCurrency(method.amount)}</TableCell>
                      <TableCell>{percentage}%</TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
