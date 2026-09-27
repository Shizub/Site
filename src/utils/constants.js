// CDN public (Cloudflare R2) : favicons, images Open Graph…
export const CDN_URL = 'https://pub-10a3d46a53444d0ebeb7b8f862a0193b.r2.dev'

// Origine de l'API réelle. En prod (Vercel) et en dev (Vite), les appels passent par
// le proxy same-origin `/api` pour éviter les soucis de CORS (cf. vercel.json / vite.config.js).
export const API_ORIGIN = 'https://dev.arsuup.fr'
export const API_URL = import.meta.env?.VITE_API_URL || '/api'

export const SITE_URL = 'https://arsuup.fr'
export const CONTACT_MAIL = 'prod@arsuup.fr'
export const INSTAGRAM_URL = 'https://www.instagram.com/arsuup_/'
export const GITHUB_URL = 'https://github.com/arsuup/Portfolio-website'
