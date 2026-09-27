<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { GITHUB_URL } from '@/utils/constants'

const route = useRoute()

/* ---- Menu "Conditions générales et politiques" ----
   Avant : ouverture uniquement au survol → inutilisable au clavier et sur mobile.
   Maintenant : bouton disclosure (clic / Entrée / Échap / clic extérieur) + survol conservé sur desktop. */
const isFrameVisible = ref(false)
const politicsWrapper = ref(null)
const politicsButton = ref(null)
let hideTimeout = null
const canHover = typeof window !== 'undefined' && window.matchMedia('(hover: hover) and (pointer: fine)').matches

// Survol = ouverture temporaire ; clic = menu "épinglé" jusqu'au clic extérieur / Échap
let pinned = false

const showFrame = () => {
  if (!canHover) return
  clearTimeout(hideTimeout)
  isFrameVisible.value = true
}
const scheduleHide = () => {
  if (!canHover || pinned) return
  clearTimeout(hideTimeout)
  hideTimeout = setTimeout(() => { isFrameVisible.value = false }, 300)
}
const toggleFrame = () => {
  clearTimeout(hideTimeout)
  if (isFrameVisible.value && !pinned && canHover) {
    pinned = true // ouvert au survol : le clic l'épingle au lieu de le refermer
    return
  }
  isFrameVisible.value = !isFrameVisible.value
  pinned = isFrameVisible.value
}
const onKeydown = (e) => {
  if (e.key === 'Escape' && isFrameVisible.value) {
    isFrameVisible.value = false
    politicsButton.value?.focus()
  }
}
const onPointerDown = (e) => {
  if (isFrameVisible.value && politicsWrapper.value && !politicsWrapper.value.contains(e.target)) {
    isFrameVisible.value = false
  }
}
const onFocusOut = (e) => {
  if (politicsWrapper.value && !politicsWrapper.value.contains(e.relatedTarget)) {
    isFrameVisible.value = false
  }
}

watch(isFrameVisible, (v) => { if (!v) pinned = false })
watch(() => route.fullPath, () => { isFrameVisible.value = false })

onMounted(() => {
  document.addEventListener('keydown', onKeydown)
  document.addEventListener('pointerdown', onPointerDown)
})
onUnmounted(() => {
  clearTimeout(hideTimeout)
  document.removeEventListener('keydown', onKeydown)
  document.removeEventListener('pointerdown', onPointerDown)
})

const buildDate = new Date(__BUILD_DATE__).toLocaleString('fr-FR', {
  day: '2-digit',
  month: 'long',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
})
const year = new Date().getFullYear()
</script>

<template>
  <a class="skip-link" href="#contenu">Aller au contenu</a>

  <header>
    <div class="content-area">
      <div class="header-left">
        <router-link to="/" class="brand" aria-label="Arsuup — accueil">
          <img class="brand-logo" src="/i/pfp.jpg" alt="" width="39" height="39">
        </router-link>
        <nav aria-label="Navigation principale">
          <router-link to="/" exact-active-class="is-active">Montage Vidéo</router-link>
          <router-link :to="{ path: '/', hash: '#contact' }" active-class="" exact-active-class="">Contact</router-link>
        </nav>
      </div>
      <div class="header-right"></div>
    </div>
  </header>

  <main id="contenu" tabindex="-1">
    <router-view />
  </main>

  <footer>
    <div class="content-area">
      <div class="footer-left">
        <p>© {{ year }} arsuup.fr</p>
        <a class="github" :href="GITHUB_URL" target="_blank" rel="noopener noreferrer" :title="'Dernier build le ' + buildDate">Github</a>
      </div>
      <div class="footer-right">
        <div
          ref="politicsWrapper"
          class="politics-wrapper"
          @mouseenter="showFrame"
          @mouseleave="scheduleHide"
          @focusout="onFocusOut"
        >
          <button
            id="politics"
            ref="politicsButton"
            class="footer-politics"
            type="button"
            aria-controls="politics-frame"
            :aria-expanded="isFrameVisible"
            @click="toggleFrame"
          >
            Conditions générales et politiques
            <svg class="chevron" :class="{ open: isFrameVisible }" width="12" height="12" viewBox="0 0 12 12" aria-hidden="true"><path d="M3 7.5 6 4.5l3 3" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </button>
          <div id="politics-frame" class="footer-politics-frame" :class="{ visible: isFrameVisible }">
            <router-link class="footer-politics-frame-button" to="/policies/legal">Mentions légales</router-link>
            <router-link class="footer-politics-frame-button" to="/policies/rgpd">Politique de confidentialité</router-link>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<style scoped>
  main {
    flex: 1;
    display: flex;
    margin-top: var(--header-h);
    flex-direction: column;
    align-items: center;
    outline: none;
  }

  header {
    height: var(--header-h);
    width: 100%;
    background: color-mix(in srgb, var(--b) 82%, transparent);
    -webkit-backdrop-filter: saturate(140%) blur(12px);
    backdrop-filter: saturate(140%) blur(12px);
    color: var(--text);
    display: flex;
    justify-content: center;
    border-bottom: solid 1px var(--border);
    position: fixed;
    top: 0;
    left: 0;
    z-index: 100;
  }
  .header-left, .header-right {
    display: flex;
    align-items: center;
  }

  .brand {
    display: flex;
    align-items: center;
    margin-right: 2rem;
    border-radius: 10px;
  }
  .brand-logo {
    height: 39px;
    width: 39px;
    user-select: none;
    border-radius: 10px;
    background: black;
    object-fit: cover;
    transition: transform .4s var(--ease-out);
  }
  .brand:hover .brand-logo { transform: rotate(-6deg) scale(1.06); }

  nav {
    display: flex;
    width: max-content;
    font-size: .9rem;
    gap: .5rem;
  }
  nav a {
    padding: .5rem .8rem;
    color: var(--textSecondary);
    border-radius: 8px;
    border: solid 1px transparent;
    transition: background .1s ease-out, color .1s ease-out;
    text-decoration: none;
  }
  nav a:hover {
    color: var(--text);
    background: var(--surface);
  }
  nav .is-active {
    color: var(--text);
    border: solid 1px var(--border);
  }

  footer {
    border-top: solid 1px var(--border);
    color: var(--text);
    display: flex;
    justify-content: center;
    padding: 1.8rem 0;
  }
  footer .content-area {
    align-items: center;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .footer-left {
    display: flex;
    gap: 2rem;
    align-items: center;
  }

  p { margin: 0; }

  .github {
    color: var(--w);
    opacity: 0.7;
    text-decoration: none;
    padding: 10px 14px;
    background: var(--chip);
    border-radius: 8px;
    width: max-content;
    transition: opacity .1s;
  }
  .github:hover { opacity: 1; }

  .footer-right {
    position: relative;
    display: flex;
    align-items: center;
  }

  .footer-politics {
    display: inline-flex;
    align-items: center;
    gap: .4rem;
    border: 0;
    background: 0;
    color: var(--textSecondary);
    font-size: 1rem;
    cursor: pointer;
    padding: 8px 6px;
    transition: color .1s;
  }
  .footer-politics:hover, .footer-politics[aria-expanded="true"] { color: var(--text); }
  .chevron { transition: transform .2s var(--ease-out); transform: rotate(180deg); }
  .chevron.open { transform: rotate(0deg); }

  .footer-politics-frame {
    background: var(--b);
    border: solid 1px var(--border);
    box-shadow: 0 10px 30px -6px #00000080;
    position: absolute;
    bottom: 100%;
    right: 0;
    margin-bottom: .75rem;
    padding: 8px;
    border-radius: 13px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    min-width: max-content;
    opacity: 0;
    visibility: hidden;
    transform: translateY(4px);
    transition: opacity 0.15s ease, transform 0.15s ease, visibility 0.15s;
    pointer-events: none;
  }
  .footer-politics-frame.visible {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
    pointer-events: auto;
  }
  .footer-politics-frame-button {
    text-align: left;
    font-size: 1rem;
    color: var(--text);
    padding: 8px 10px;
    border-radius: 8px;
    transition: background 0.15s ease, color 0.15s ease;
    user-select: none;
    text-decoration: none;
  }
  .footer-politics-frame-button:hover,
  .footer-politics-frame-button.router-link-active {
    background-color: var(--w);
    color: var(--b);
  }

  @media (max-width: 600px) {
    nav a { padding: .45rem .6rem; }
    .brand { margin-right: 1rem; }
    .footer-left { gap: 1rem; }
    .footer-right { width: 100%; }
    .footer-politics { padding-left: 0; }
    .footer-politics-frame { left: 0; right: auto; }
  }
</style>
