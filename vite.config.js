import { fileURLToPath, URL } from 'node:url'
import { CDN_URL, API_ORIGIN } from './src/utils/constants.js'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Markdown from 'unplugin-vue-markdown/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue({ include: [/\.vue$/, /\.md$/] }),
    {
      name: 'html-transform',
      transformIndexHtml(html) {
        return html.replace(/%CDN_URL%/g, CDN_URL)
      }
    },
    // La date de révision des docs légales est lue dans le frontmatter (`updated:`)
    // et plus dans le mtime du fichier (qui vaut la date du clone sur Vercel).
    Markdown({ exportFrontmatter: true }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  define: {
    __BUILD_DATE__: JSON.stringify(new Date().toISOString()),
  },
  build: {
    // hls.js (~575 Ko) n'est chargé qu'à la première lecture vidéo
    chunkSizeWarningLimit: 600,
  },
  server: {
    proxy: {
      '/api': { target: API_ORIGIN, changeOrigin: true },
    },
  },
})
