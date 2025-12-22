import { useState } from "react";
import { useParams, useLocation } from "wouter";
import { trpc } from "@/lib/trpc";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Separator } from "@/components/ui/separator";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  ArrowLeft,
  Phone,
  Mail,
  MapPin,
  Calendar,
  TrendingUp,
  MessageSquare,
  Bot,
  User,
  DollarSign,
  Home,
  Sparkles,
  Clock,
} from "lucide-react";
import { toast } from "sonner";
// Função helper para formatar moeda
const formatCurrency = (cents: number) => {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(cents / 100);
};

export default function ClientDetail() {
  const params = useParams();
  const leadId = parseInt(params.id || "0");
  const [, setLocation] = useLocation();
  const [isAnalyzing, setIsAnalyzing] = useState(false);

  // Queries
  const { data: lead, refetch: refetchLead } = trpc.leads.getById.useQuery({ id: leadId });
  const { data: interactions } = trpc.interactions.getByLeadId.useQuery({ leadId });
  const { data: messages } = trpc.integration.getHistory.useQuery(
    { phone: lead?.phone || "" },
    { enabled: !!lead?.phone }
  );

  // Mutation para análise automática
  const analyzeConversation = trpc.integration.analyzeConversation.useMutation({
    onSuccess: (data) => {
      if (data.success) {
        toast.success("Conversa analisada com sucesso!");
        refetchLead();
      } else {
        toast.error(data.error || "Erro ao analisar conversa");
      }
      setIsAnalyzing(false);
    },
    onError: (error) => {
      toast.error("Erro ao analisar conversa: " + error.message);
      setIsAnalyzing(false);
    },
  });

  const handleAnalyzeConversation = async () => {
    if (!lead?.phone) {
      toast.error("Cliente não possui telefone cadastrado");
      return;
    }

    setIsAnalyzing(true);
    analyzeConversation.mutate({ phone: lead.phone });
  };

  if (!lead) {
    return (
      <div className="p-8">
        <p>Carregando...</p>
      </div>
    );
  }

  const qualificationColors = {
    quente: "bg-red-100 text-red-800 border-red-200",
    morno: "bg-yellow-100 text-yellow-800 border-yellow-200",
    frio: "bg-blue-100 text-blue-800 border-blue-200",
    nao_qualificado: "bg-gray-100 text-gray-800 border-gray-200",
  };

  const urgencyColors = {
    urgente: "bg-red-100 text-red-800",
    alta: "bg-orange-100 text-orange-800",
    media: "bg-yellow-100 text-yellow-800",
    baixa: "bg-green-100 text-green-800",
  };

  const sourceLabels = {
    site: "Site",
    whatsapp: "WhatsApp",
    instagram: "Instagram",
    facebook: "Facebook",
    indicacao: "Indicação",
    portal_zap: "ZAP Imóveis",
    portal_vivareal: "VivaReal",
    portal_olx: "OLX",
    google: "Google",
    outro: "Outro",
  };

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setLocation("/admin/clients")}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-3xl font-bold">{lead.name}</h1>
            <p className="text-muted-foreground">
              Cliente desde {new Date(lead.createdAt).toLocaleDateString("pt-BR")}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={handleAnalyzeConversation}
            disabled={isAnalyzing || !lead.phone}
          >
            <Sparkles className="h-4 w-4 mr-2" />
            {isAnalyzing ? "Analisando..." : "Analisar Conversa"}
          </Button>
        </div>
      </div>

      {/* Cards de Resumo */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Qualificação
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Badge className={qualificationColors[lead.qualification]}>
              {lead.qualification.toUpperCase()}
            </Badge>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Urgência
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Badge className={urgencyColors[lead.urgencyLevel || "baixa"]}>
              {(lead.urgencyLevel || "baixa").toUpperCase()}
            </Badge>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Origem
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-lg font-semibold">
              {sourceLabels[lead.source || "site"]}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Orçamento
            </CardTitle>
          </CardHeader>
          <CardContent>
            {lead.budgetMin || lead.budgetMax ? (
              <p className="text-lg font-semibold">
                {lead.budgetMin ? formatCurrency(lead.budgetMin) : "—"} até{" "}
                {lead.budgetMax ? formatCurrency(lead.budgetMax) : "—"}
              </p>
            ) : (
              <p className="text-muted-foreground">Não informado</p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Tabs de Conteúdo */}
      <Tabs defaultValue="profile" className="space-y-4">
        <TabsList>
          <TabsTrigger value="profile">
            <User className="h-4 w-4 mr-2" />
            Perfil
          </TabsTrigger>
          <TabsTrigger value="whatsapp">
            <MessageSquare className="h-4 w-4 mr-2" />
            WhatsApp ({messages?.length || 0})
          </TabsTrigger>
          <TabsTrigger value="interactions">
            <Clock className="h-4 w-4 mr-2" />
            Interações ({interactions?.length || 0})
          </TabsTrigger>
        </TabsList>

        {/* Tab: Perfil */}
        <TabsContent value="profile" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Informações de Contato */}
            <Card>
              <CardHeader>
                <CardTitle>Informações de Contato</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {lead.phone && (
                  <div className="flex items-center gap-3">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Telefone</p>
                      <p className="font-medium">{lead.phone}</p>
                    </div>
                  </div>
                )}
                {lead.email && (
                  <div className="flex items-center gap-3">
                    <Mail className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">E-mail</p>
                      <p className="font-medium">{lead.email}</p>
                    </div>
                  </div>
                )}
                {lead.whatsapp && (
                  <div className="flex items-center gap-3">
                    <MessageSquare className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">WhatsApp</p>
                      <p className="font-medium">{lead.whatsapp}</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Preferências */}
            <Card>
              <CardHeader>
                <CardTitle>Preferências</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {lead.transactionInterest && (
                  <div className="flex items-center gap-3">
                    <DollarSign className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Interesse</p>
                      <p className="font-medium capitalize">{lead.transactionInterest}</p>
                    </div>
                  </div>
                )}
                {lead.preferredPropertyTypes && (
                  <div className="flex items-center gap-3">
                    <Home className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Tipos de Imóvel</p>
                      <p className="font-medium">{lead.preferredPropertyTypes}</p>
                    </div>
                  </div>
                )}
                {lead.preferredNeighborhoods && (
                  <div className="flex items-center gap-3">
                    <MapPin className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Bairros</p>
                      <p className="font-medium">{lead.preferredNeighborhoods}</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Notas */}
          {lead.notes && (
            <Card>
              <CardHeader>
                <CardTitle>Notas e Observações</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="whitespace-pre-wrap text-sm">{lead.notes}</div>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        {/* Tab: WhatsApp */}
        <TabsContent value="whatsapp">
          <Card>
            <CardHeader>
              <CardTitle>Histórico de Conversas WhatsApp</CardTitle>
              <CardDescription>
                {messages?.length || 0} mensagens trocadas
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ScrollArea className="h-[500px] pr-4">
                {messages && messages.length > 0 ? (
                  <div className="space-y-4">
                    {messages.map((msg) => (
                      <div
                        key={msg.id}
                        className={`flex gap-3 ${
                          msg.role === "assistant" ? "flex-row-reverse" : ""
                        }`}
                      >
                        <div
                          className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
                            msg.role === "assistant"
                              ? "bg-primary text-primary-foreground"
                              : "bg-muted"
                          }`}
                        >
                          {msg.role === "assistant" ? (
                            <Bot className="h-4 w-4" />
                          ) : (
                            <User className="h-4 w-4" />
                          )}
                        </div>
                        <div
                          className={`flex-1 ${
                            msg.role === "assistant" ? "text-right" : ""
                          }`}
                        >
                          <div
                            className={`inline-block p-3 rounded-lg ${
                              msg.role === "assistant"
                                ? "bg-primary text-primary-foreground"
                                : "bg-muted"
                            }`}
                          >
                            <p className="text-sm">{msg.message}</p>
                          </div>
                          <p className="text-xs text-muted-foreground mt-1">
                            {new Date(msg.createdAt).toLocaleString("pt-BR")}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-12 text-muted-foreground">
                    <MessageSquare className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>Nenhuma mensagem WhatsApp encontrada</p>
                  </div>
                )}
              </ScrollArea>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Tab: Interações */}
        <TabsContent value="interactions">
          <Card>
            <CardHeader>
              <CardTitle>Timeline de Interações</CardTitle>
              <CardDescription>
                Histórico completo de atividades com este cliente
              </CardDescription>
            </CardHeader>
            <CardContent>
              {interactions && interactions.length > 0 ? (
                <div className="space-y-4">
                  {interactions.map((interaction) => (
                    <div key={interaction.id} className="flex gap-4 border-l-2 border-muted pl-4 pb-4">
                      <div className="flex-shrink-0 w-2 h-2 rounded-full bg-primary mt-2" />
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-1">
                          <p className="font-medium capitalize">{interaction.type}</p>
                          <p className="text-sm text-muted-foreground">
                            {new Date(interaction.createdAt).toLocaleDateString("pt-BR")}
                          </p>
                        </div>
                        {interaction.description && (
                          <p className="text-sm text-muted-foreground">{interaction.description}</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-12 text-muted-foreground">
                  <Clock className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>Nenhuma interação registrada</p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
