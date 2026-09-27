import { createRouter, createWebHistory } from 'vue-router'

const TITLE = 'Arsuup'

const routes = [
  { path: "/", component: () => import("@/views/MainView.vue"), meta: { title: 'Arsuup — Portfolio montage vidéo & motion design' } },
  { path: "/policies/legal", component: () => import("@/views/legal/LegalView.vue"), meta: { title: `Mentions légales — ${TITLE}` } },
  { path: "/policies/rgpd", component: () => import("@/views/legal/LegalRgpdView.vue"), meta: { title: `Politique de confidentialité — ${TITLE}` } },
  { path: "/:pathMatch(.*)*", component: () => import("@/views/error/NotFound.vue"), meta: { title: `Page introuvable — ${TITLE}` } },
]

const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

const router = createRouter({
  history: createWebHistory(),
  routes: routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) {
      return {
        el: to.hash,
        top: 65 + 16,
        behavior: prefersReducedMotion() ? 'auto' : 'smooth'
      }
    }
    return { top: 0 }
  }
})

// Chaque page a son propre <title> (avant : "Arsuup - Portfolio" partout)
router.afterEach((to) => {
  document.title = to.meta.title || TITLE
})

export default router
