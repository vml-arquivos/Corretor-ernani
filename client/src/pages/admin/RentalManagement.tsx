import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Plus, Edit2, Trash2, FileText, DollarSign, AlertCircle } from "lucide-react";

export default function RentalManagement() {
  const [rentals, setRentals] = useState([
    {
      id: 1,
      property: "Apto 101",
      tenant: "João Silva",
      rent: 2000,
      commission: 100,
      startDate: "2024-01-15",
      status: "ativo",
      nextPaymentDate: "2025-02-15",
    },
    {
      id: 2,
      property: "Apto 202",
      tenant: "Maria Santos",
      rent: 2500,
      commission: 125,
      startDate: "2024-03-10",
      status: "ativo",
      nextPaymentDate: "2025-02-10",
    },
    {
      id: 3,
      property: "Casa 45",
      tenant: "Pedro Oliveira",
      rent: 3000,
      commission: 150,
      startDate: "2023-06-20",
      status: "ativo",
      nextPaymentDate: "2025-02-20",
    },
  ]);

  const [selectedRental, setSelectedRental] = useState<any>(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("rentals");

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(value);

  const formatDate = (date: string) => new Date(date).toLocaleDateString("pt-BR");

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Gestão de Aluguel</h1>
        <p className="text-muted-foreground">Gerenciar aluguéis, pagamentos, despesas e contratos</p>
      </div>

      {/* Abas */}
      <div className="flex gap-2 border-b">
        <button
          onClick={() => setActiveTab("rentals")}
          className={`px-4 py-2 font-medium ${activeTab === "rentals" ? "border-b-2 border-primary text-primary" : "text-muted-foreground"}`}
        >
          Aluguéis
        </button>
        <button
          onClick={() => setActiveTab("payments")}
          className={`px-4 py-2 font-medium ${activeTab === "payments" ? "border-b-2 border-primary text-primary" : "text-muted-foreground"}`}
        >
          Pagamentos
        </button>
        <button
          onClick={() => setActiveTab("expenses")}
          className={`px-4 py-2 font-medium ${activeTab === "expenses" ? "border-b-2 border-primary text-primary" : "text-muted-foreground"}`}
        >
          Despesas
        </button>
        <button
          onClick={() => setActiveTab("contracts")}
          className={`px-4 py-2 font-medium ${activeTab === "contracts" ? "border-b-2 border-primary text-primary" : "text-muted-foreground"}`}
        >
          Contratos
        </button>
      </div>

      {/* Aba: Aluguéis */}
      {activeTab === "rentals" && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Aluguéis Ativos</h2>
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Novo Aluguel
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Criar Novo Aluguel</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label>Imóvel</Label>
                    <Input placeholder="Selecione o imóvel" />
                  </div>
                  <div className="space-y-2">
                    <Label>Inquilino</Label>
                    <Input placeholder="Nome do inquilino" />
                  </div>
                  <div className="space-y-2">
                    <Label>Aluguel Mensal (R$)</Label>
                    <Input type="number" placeholder="0.00" />
                  </div>
                  <div className="space-y-2">
                    <Label>Comissão (%)</Label>
                    <Input type="number" placeholder="5" />
                  </div>
                  <div className="space-y-2">
                    <Label>Data de Início</Label>
                    <Input type="date" />
                  </div>
                  <Button className="w-full">Criar Aluguel</Button>
                </div>
              </DialogContent>
            </Dialog>
          </div>

          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Imóvel</TableHead>
                  <TableHead>Inquilino</TableHead>
                  <TableHead>Aluguel</TableHead>
                  <TableHead>Comissão</TableHead>
                  <TableHead>Próx. Pagamento</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rentals.map((rental) => (
                  <TableRow key={rental.id}>
                    <TableCell className="font-medium">{rental.property}</TableCell>
                    <TableCell>{rental.tenant}</TableCell>
                    <TableCell>{formatCurrency(rental.rent)}</TableCell>
                    <TableCell>{formatCurrency(rental.commission)}</TableCell>
                    <TableCell>{formatDate(rental.nextPaymentDate)}</TableCell>
                    <TableCell>
                      <Badge className="bg-green-100 text-green-800">{rental.status.toUpperCase()}</Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button variant="ghost" size="sm">
                          <Edit2 className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="sm">
                          <Trash2 className="h-4 w-4 text-red-500" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>
      )}

      {/* Aba: Pagamentos */}
      {activeTab === "payments" && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Pagamentos de Aluguel</h2>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Registrar Pagamento
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Esperado Este Mês</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">R$ 7.500,00</div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Recebido</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-green-600">R$ 4.500,00</div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Pendente</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-red-600">R$ 3.000,00</div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Histórico de Pagamentos</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Inquilino</TableHead>
                      <TableHead>Imóvel</TableHead>
                      <TableHead>Valor</TableHead>
                      <TableHead>Data Vencimento</TableHead>
                      <TableHead>Data Pagamento</TableHead>
                      <TableHead>Método</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    <TableRow>
                      <TableCell>João Silva</TableCell>
                      <TableCell>Apto 101</TableCell>
                      <TableCell>R$ 2.000,00</TableCell>
                      <TableCell>15/01/2025</TableCell>
                      <TableCell>15/01/2025</TableCell>
                      <TableCell>PIX</TableCell>
                      <TableCell>
                        <Badge className="bg-green-100 text-green-800">PAGO</Badge>
                      </TableCell>
                    </TableRow>
                    <TableRow>
                      <TableCell>Maria Santos</TableCell>
                      <TableCell>Apto 202</TableCell>
                      <TableCell>R$ 2.500,00</TableCell>
                      <TableCell>10/01/2025</TableCell>
                      <TableCell>-</TableCell>
                      <TableCell>-</TableCell>
                      <TableCell>
                        <Badge className="bg-red-100 text-red-800">ATRASADO</Badge>
                      </TableCell>
                    </TableRow>
                    <TableRow>
                      <TableCell>Pedro Oliveira</TableCell>
                      <TableCell>Casa 45</TableCell>
                      <TableCell>R$ 3.000,00</TableCell>
                      <TableCell>20/01/2025</TableCell>
                      <TableCell>-</TableCell>
                      <TableCell>-</TableCell>
                      <TableCell>
                        <Badge className="bg-yellow-100 text-yellow-800">PENDENTE</Badge>
                      </TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Aba: Despesas */}
      {activeTab === "expenses" && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Despesas de Manutenção</h2>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Registrar Despesa
            </Button>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Despesas Registradas</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Imóvel</TableHead>
                      <TableHead>Tipo</TableHead>
                      <TableHead>Valor</TableHead>
                      <TableHead>Data</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    <TableRow>
                      <TableCell>Apto 101</TableCell>
                      <TableCell>Manutenção</TableCell>
                      <TableCell>R$ 500,00</TableCell>
                      <TableCell>10/01/2025</TableCell>
                      <TableCell>
                        <Badge className="bg-green-100 text-green-800">PAGO</Badge>
                      </TableCell>
                    </TableRow>
                    <TableRow>
                      <TableCell>Casa 45</TableCell>
                      <TableCell>Reparos</TableCell>
                      <TableCell>R$ 1.200,00</TableCell>
                      <TableCell>12/01/2025</TableCell>
                      <TableCell>
                        <Badge className="bg-yellow-100 text-yellow-800">PENDENTE</Badge>
                      </TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Aba: Contratos */}
      {activeTab === "contracts" && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Contratos de Aluguel</h2>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Gerar Contrato
            </Button>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Contratos</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Nº Contrato</TableHead>
                      <TableHead>Inquilino</TableHead>
                      <TableHead>Imóvel</TableHead>
                      <TableHead>Período</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Ações</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    <TableRow>
                      <TableCell>CT-2024-001</TableCell>
                      <TableCell>João Silva</TableCell>
                      <TableCell>Apto 101</TableCell>
                      <TableCell>15/01/2024 - 15/01/2025</TableCell>
                      <TableCell>
                        <Badge className="bg-green-100 text-green-800">ASSINADO</Badge>
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="sm">
                          <FileText className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
