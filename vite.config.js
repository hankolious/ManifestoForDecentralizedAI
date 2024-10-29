import { fileURLToPath, URL } from 'url';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import environment from 'vite-plugin-environment';
import { resolve } from 'path';

export default defineConfig({
  root: ".", // Explicitly set root to the directory containing vite.config.js and index.html
  build: {
    outDir: 'dist', // Output directory for build files
    rollupOptions: {
      input: resolve('./index.html'), // Explicitly specify the path to index.html
    },
  },
  optimizeDeps: {
    esbuildOptions: {
      define: {
        global: "globalThis",
      },
    },
  },
  publicDir: "./src/DeAIManifesto_frontend/public",
  server: {
    proxy: {
      "/api": {
        target: "http://127.0.0.1:4943",
        changeOrigin: true,
      },
    },
  },
  plugins: [
    react(),
    environment("all", { prefix: "CANISTER_" }),
    environment("all", { prefix: "DFX_" }),
  ],
  resolve: {
    alias: [
      {
        find: "declarations",
        replacement: fileURLToPath(
          new URL("../declarations", import.meta.url)
        ),
      },
    ],
  },
});
