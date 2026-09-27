# Portfolio Arsuup — version corrigée (v2.1)

Fork de travail de [arsuup/Portfolio-website](https://github.com/arsuup/Portfolio-website) (branche V2 / dev.arsuup.fr) :
mêmes images, même DA, bugs corrigés + quelques améliorations. Le détail est dans **[REVIEW.md](./REVIEW.md)**.

## Lancer en local

```bash
npm install
npm run dev      # http://localhost:5173 — /api est proxifié vers dev.arsuup.fr
npm run build && npm run preview
```

## Déployer sur Vercel (gratuit)

1. https://vercel.com/new → **Import Git Repository** → choisir `Shizub/Site`.
2. Framework : **Vite** (détecté tout seul). Rien d'autre à configurer.
3. Pour déployer cette branche en prod : *Settings → Git → Production Branch* =
   `claude/arsuup-site-review-redesign-ysmkbh` (ou merger dans `main`).

`vercel.json` gère :
- le fallback SPA (les URLs `/policies/legal`, `/policies/rgpd` et la 404 marchent au rechargement) ;
- un proxy `/api/*` → `https://dev.arsuup.fr/api/*` (pas de souci de CORS) ;
- le cache long des assets et quelques en-têtes de sécurité.

Si l'API est injoignable (ex. protection anti-bot Cloudflare qui bloque Vercel), le site affiche
un aperçu des derniers projets (`src/data/fallback.js`) + un bouton « Réessayer » au lieu d'une page vide.

Variable optionnelle : `VITE_API_URL` pour appeler une autre API (ex. `https://arsuup.fr/api`).
