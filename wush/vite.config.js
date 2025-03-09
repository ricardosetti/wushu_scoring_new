import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  define: {
    'process.env.VITE_SERVER_HOST': JSON.stringify(process.env.VITE_SERVER_HOST || 'localhost'),
    'process.env.VITE_SERVER_PORT': JSON.stringify(process.env.VITE_SERVER_PORT || '5000'),
  },
  base: '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    minify: true,
  },
});