import path from 'path';
import { defineConfig } from 'vite';
import solid from 'vite-plugin-solid';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [solid()],
  
  // Tauri expects a fixed port
  server: {
    port: 5173,
    strictPort: true,
  },
  
  // Produce sourcemaps for debugging
  build: {
    sourcemap: true,
    target: 'esnext',
    minify: 'esbuild',
    outDir: 'dist',
  },
  
  // Path aliases
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  
  // Env variables prefix
  envPrefix: ['VITE_', 'TAURI_'],
});
