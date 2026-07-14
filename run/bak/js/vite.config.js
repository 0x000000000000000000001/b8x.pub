import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  root: 'public',
  resolve: {
    alias: {
      '../output': path.resolve(__dirname, './output')
    }
  },
  build: {
    outDir: '../dist',
    emptyOutDir: false,
    manifest: true,
    chunkSizeWarningLimit: 1000,
    rollupOptions: {
      output: {
        // We use an underscore instead of a hyphen before the hash.
        // This prevents double hyphens (if the hash starts with a hyphen)
        // which would otherwise be stripped by Nginx SEO rewrite rules (dashes.conf),
        // causing broken asset URLs and permanently cached 301 redirects in browsers.
        assetFileNames: 'assets/[name]_[hash][extname]',
        chunkFileNames: 'assets/[name]_[hash].js',
        entryFileNames: 'assets/[name]_[hash].js',
        manualChunks(id) {
          if (id.includes('node_modules')) 
            return 'node_modules'; 
        }
      }
    } 
  },
  server: {
    host: true, // Docker
    port: 8080,
    open: false,
    allowedHosts: [process.env.DNS_LEVEL_2_GTE],
    proxy: {
      '/api': {
        target: 'http://api:80',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
});
