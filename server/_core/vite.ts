 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/server/_core/vite.ts b/server/_core/vite-dev.ts
similarity index 73%
rename from server/_core/vite.ts
rename to server/_core/vite-dev.ts
index b01a4a9549e93dbd4f8f4155d2828e39e9c46b22..fa956773abf68d6d9949585c6116ddfe80dd30c4 100644
--- a/server/_core/vite.ts
+++ b/server/_core/vite-dev.ts
@@ -25,40 +25,25 @@ export async function setupVite(app: Express, server: Server) {
     const url = req.originalUrl;
 
     try {
       const clientTemplate = path.resolve(
         import.meta.dirname,
         "../..",
         "client",
         "index.html"
       );
 
       // always reload the index.html file from disk incase it changes
       let template = await fs.promises.readFile(clientTemplate, "utf-8");
       template = template.replace(
         `src="/src/main.tsx"`,
         `src="/src/main.tsx?v=${nanoid()}"`
       );
       const page = await vite.transformIndexHtml(url, template);
       res.status(200).set({ "Content-Type": "text/html" }).end(page);
     } catch (e) {
       vite.ssrFixStacktrace(e as Error);
       next(e);
     }
   });
 }
 
-export function serveStatic(app: Express) {
-  const distPath = path.resolve(import.meta.dirname, "../\..", "dist", "client");
-  if (!fs.existsSync(distPath)) {
-    console.error(
-      `Could not find the build directory: ${distPath}, make sure to build the client first`
-    );
-  }
-
-  app.use(express.static(distPath));
-
-  // fall through to index.html if the file doesn't exist
-  app.use("*", (_req, res) => {
-    res.sendFile(path.resolve(distPath, "index.html"));
-  });
-}
 
EOF
)
