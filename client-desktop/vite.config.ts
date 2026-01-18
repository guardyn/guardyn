import path from 'path';
import { defineConfig } from 'vite';
import solid from 'vite-plugin-solid';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    solid({
      // Disable SSR for tests - use client-only components
      ssr: false,
    }),
  ],

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
      // Force client-side solid-js in tests
      'solid-js/store': path.resolve(__dirname, 'node_modules/solid-js/store/dist/store.js'),
      'solid-js/web': path.resolve(__dirname, 'node_modules/solid-js/web/dist/web.js'),
      'solid-js': path.resolve(__dirname, 'node_modules/solid-js/dist/solid.js'),
    },
    conditions: ['browser', 'development'],
  },
  
  // Env variables prefix
  envPrefix: ['VITE_', 'TAURI_'],

  // Test configuration
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.tsx'],
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    // Force client-side transform for solid-js components
    testTransformMode: {
      web: ['/.[jt]sx?$/'],
    },
    // Ensure solid-js and router work correctly in tests
    deps: {
      optimizer: {
        web: {
          include: ['@solidjs/router', 'solid-js'],
        },
      },
    },
    // Use browser-like environment for solid components
    server: {
      deps: {
        inline: [/solid-js/, /@solidjs\/router/],
      },
    },
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/test/**', 'src/**/*.d.ts'],
    },
  },
});
