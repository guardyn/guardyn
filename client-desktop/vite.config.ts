import path from 'path';
import { defineConfig, type PluginOption } from 'vite';
import solid from 'vite-plugin-solid';
import { visualizer } from 'rollup-plugin-visualizer';

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [
    solid({
      // Disable SSR for tests - use client-only components
      ssr: false,
    }),
    // Bundle analyzer - only in analyze mode
    mode === 'analyze' &&
      visualizer({
        open: true,
        filename: 'dist/bundle-stats.html',
        gzipSize: true,
        brotliSize: true,
        template: 'treemap', // 'treemap', 'sunburst', 'network'
      }) as PluginOption,
  ].filter(Boolean),

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
    // Code splitting configuration
    rollupOptions: {
      output: {
        // Manual chunk splitting for optimal caching
        manualChunks: {
          // Vendor chunk for dependencies
          vendor: ['solid-js', '@solidjs/router'],
          // Tauri APIs in separate chunk
          tauri: [
            '@tauri-apps/api',
            '@tauri-apps/plugin-dialog',
            '@tauri-apps/plugin-fs',
            '@tauri-apps/plugin-notification',
            '@tauri-apps/plugin-os',
            '@tauri-apps/plugin-process',
            '@tauri-apps/plugin-shell',
          ],
        },
        // Chunk naming for easier debugging
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]',
      },
    },
    // Report compressed sizes
    reportCompressedSize: true,
    // Warn if chunks exceed 500kb
    chunkSizeWarningLimit: 500,
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
}));
