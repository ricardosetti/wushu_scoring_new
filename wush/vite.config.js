import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import vueDevTools from 'vite-plugin-vue-devtools';
import tailwindcss from 'tailwindcss';
import autoprefixer from 'autoprefixer';

export default defineConfig({
  plugins: [vue(), vueDevTools()],
  css: {
    postcss: {
      plugins: [
        tailwindcss,
        autoprefixer,
      ],
    },
  },
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