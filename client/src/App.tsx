import { Toaster } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import NotFound from "@/pages/NotFound";
import { Route, Switch } from "wouter";
import ErrorBoundary from "./components/ErrorBoundary";
import { ThemeProvider } from "./contexts/ThemeContext";

import AdminLayout from "./components/AdminLayout";
import Home from "./pages/Home";
import PropertyDetailPage from "./pages/PropertyDetail";
import BlogPosts from "./pages/admin/BlogPosts";
import BlogPostEdit from "./pages/admin/BlogPostEdit";
import Properties from "./pages/Properties";
import Blog from "./pages/Blog";
import BlogPost from "./pages/BlogPost";
import About from "./pages/About";
import SimulatorPage from "./pages/Simulator";
import Contact from "./pages/Contact";
import Dashboard from "./pages/admin/Dashboard";
import PropertiesAdmin from "./pages/admin/Properties";
import PropertyEdit from "./pages/admin/PropertyEdit";
import PropertyNew from "./pages/admin/PropertyNew";
import LeadsAdmin from "./pages/admin/Leads";
import LeadEdit from "./pages/admin/LeadEdit";
import ClientManagement from "./pages/admin/ClientManagement";
import FollowUp from "./pages/admin/FollowUp";
import Analytics from "./pages/admin/Analytics";
import Settings from "./pages/admin/Settings";
import Owners from "./pages/admin/Owners";
import ClientDetail from "./pages/admin/ClientDetail";
import RentalManagement from "./pages/admin/RentalManagement";
import RentalReports from "./pages/admin/RentalReports";

function Router() {
  return (
    <Switch>
      {/* Public routes */}
      <Route path={"/"} component={Home} />
      <Route path="/imoveis" component={Properties} />
      <Route path="/imovel/:id" component={PropertyDetailPage} />
      <Route path="/blog" component={Blog} />
      <Route path="/blog/:slug" component={BlogPost} />
      <Route path="/quem-somos" component={About} />
      <Route path="/simulador-financiamento" component={SimulatorPage} />
      <Route path="/contato" component={Contact} />
      
      {/* Admin routes */}
      <Route path="/admin/analytics">
        {() => (
          <AdminLayout>
            <Analytics />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin">
        {() => (
          <AdminLayout>
            <Dashboard />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/properties">
        {() => (
          <AdminLayout>
            <PropertiesAdmin />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/properties/new">
        {() => (
          <AdminLayout>
            <PropertyNew />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/properties/:id">
        {(params) => <PropertyEdit />}
      </Route>
      <Route path="/admin/leads">
        {() => (
          <AdminLayout>
            <LeadsAdmin />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/leads/new">
        {() => <LeadEdit />}
      </Route>
      <Route path="/imovel/:id">
        {(params) => <PropertyDetailPage />}
      </Route>
      <Route path="/admin/clients/:id">
        {(params) => (
          <AdminLayout>
            <ClientDetail />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/clients">
        {() => (
          <AdminLayout>
            <ClientManagement />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/blog">
        {() => (
          <AdminLayout>
            <BlogPosts />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/blog/new">
        {() => (
          <AdminLayout>
            <BlogPostEdit />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/blog/:id/edit">
        {() => (
          <AdminLayout>
            <BlogPostEdit />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/followup">
        {() => (
          <AdminLayout>
            <FollowUp />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/settings">
        {() => (
          <AdminLayout>
            <Settings />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/owners">
        {() => (
          <AdminLayout>
            <Owners />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/rentals">
        {() => (
          <AdminLayout>
            <RentalManagement />
          </AdminLayout>
        )}
      </Route>
      <Route path="/admin/rental-reports">
        {() => (
          <AdminLayout>
            <RentalReports />
          </AdminLayout>
        )}
      </Route>
      
      <Route path="{/404}" component={NotFound} />
      {/* Final fallback route */}
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <ErrorBoundary>
      <ThemeProvider defaultTheme="light">
        <TooltipProvider>
          <Toaster />
          <Router />
        </TooltipProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;
