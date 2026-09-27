Version corrigée de [dev.arsuup.fr](https://dev.arsuup.fr) : mêmes images, même DA, bugs corrigés et quelques ajouts.

## Téléchargements
| Fichier | Contenu |
|---|---|
| `arsuup-portfolio-…-site.zip` | Le site **déjà buildé** (contenu de `dist/`). À déposer tel quel sur Vercel, Netlify, Cloudflare Pages ou n'importe quel hébergeur statique. |
| `arsuup-portfolio-…-source.zip` | Le code source (Vue 3 + Vite) : `npm install` puis `npm run dev`. |
| `REVIEW.md` | La review complète : bugs trouvés, corrections, idées. |

## En bref
- 🐛 Dates en timestamp brut, TikToks rognés, miniatures YouTube manquantes, avatar « ? », menu du footer inutilisable sur mobile, sidebar qui ne reste pas fixe, bouton Play mal centré sur Firefox…
- ♿ Navigation au clavier, focus visible, contrastes, `lang="fr"`, titres structurés.
- ⚡ hls.js chargé seulement au premier Play (≈ 45 Ko au chargement initial), police auto-hébergée, previews en pause hors écran.
- ✨ Squelettes de chargement, secours si l'API tombe, badge « À la une », bouton copier le mail, carrousel TikTok sur mobile.

> ℹ️ Le site appelle l'API via `/api`. Sur Vercel, le proxy est déjà configuré dans `vercel.json`. Ailleurs, rebuild avec `VITE_API_URL=https://dev.arsuup.fr/api` (si l'API autorise le CORS) ou configure un proxy équivalent.
