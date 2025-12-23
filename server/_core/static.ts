 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/server/_core/static.ts b/server/_core/static.ts
new file mode 100644
index 0000000000000000000000000000000000000000..bb4b76df2fe4a2536d2ea79889c2703a9592feb8
--- /dev/null
+++ b/server/_core/static.ts
@@ -0,0 +1,28 @@
+import express, { type Express } from "express";
+import fs from "fs";
+import path from "path";
+import { fileURLToPath } from "url";
+
+const currentDir = path.dirname(fileURLToPath(import.meta.url));
+
+export function serveStatic(app: Express) {
+  const distPath = path.resolve(currentDir, "../..", "dist", "client");
+  if (!fs.existsSync(distPath)) {
+    console.error(
+      `Could not find the build directory: ${distPath}, make sure to build the client first`
+    );
+    app.use((_req, res) => {
+      res
+        .status(500)
+        .send("Client build not found. Please run 'pnpm run build:client' before starting.");
+    });
+    return;
+  }
+
+  app.use(express.static(distPath));
+
+  // fall through to index.html if the file doesn't exist
+  app.use("*", (_req, res) => {
+    res.sendFile(path.resolve(distPath, "index.html"));
+  });
+}
 
EOF
)
