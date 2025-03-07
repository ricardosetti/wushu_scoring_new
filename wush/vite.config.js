import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  base: '/', // Ensure base path is correct
  build: {
    outDir: 'dist', // Output directory for production build
    assetsDir: 'assets',
    minify: true, // Minify for production
  },
});