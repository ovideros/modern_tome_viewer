import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

// Relative base so the built site works from a GitHub Pages sub-path,
// a local file:// open, or any static host without extra configuration.
export default defineConfig({
  base: './',
  plugins: [react(), tailwindcss()],
  build: {
    target: 'es2022',
    // The talent dataset lives in public/data and is fetched at runtime,
    // so it never inflates the JS bundle.
    chunkSizeWarningLimit: 900,
  },
});
