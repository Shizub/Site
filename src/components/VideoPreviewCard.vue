<script setup>
import { onBeforeUnmount, onMounted, ref } from "vue"
import { loadHlsPrioritized } from "@/utils/lazyqueue"
import { API_ORIGIN, API_URL } from "@/utils/constants"
import { isHls, throughProxy } from "@/utils/format"

const props = defineProps({
  stream: String,
  title: String,
  promote: Boolean,
})

const card = ref(null)
const video = ref(null)
const ready = ref(false)
const paused = ref(true)
const failed = ref(!props.stream)

let hls = null
let observer = null
let attached = false
let visible = false

const reducedMotion = typeof window !== "undefined" && window.matchMedia("(prefers-reduced-motion: reduce)").matches
// L'utilisateur a-t-il mis en pause manuellement ? (on ne relance pas au scroll)
let userPaused = reducedMotion

async function attach() {
  if (attached || failed.value) return
  attached = true
  const el = video.value
  const src = throughProxy(props.stream, API_ORIGIN, API_URL)

  if (isHls(src) && !el.canPlayType("application/vnd.apple.mpegurl")) {
    const { default: Hls } = await import("hls.js")
    if (!Hls.isSupported()) { failed.value = true; return }
    await loadHlsPrioritized(() => new Promise((resolve) => {
      hls = new Hls({
        startLevel: 0,
        capLevelToPlayerSize: true,
        maxBufferLength: 6,
        maxMaxBufferLength: 12,
        maxLoadingDelay: 4,
        backBufferLength: 10,
        enableWorker: true,
      })
      hls.loadSource(src)
      hls.attachMedia(el)
      hls.once(Hls.Events.MANIFEST_PARSED, resolve)
      hls.on(Hls.Events.ERROR, (_, data) => {
        if (data.fatal) { failed.value = true; resolve() }
      })
    }))
  } else {
    el.src = src // Safari (HLS natif) ou MP4
  }
  if (visible && !userPaused) play()
}

function play() {
  const el = video.value
  if (!el) return
  el.muted = true
  el.play().catch(() => {})
}

function togglePlayback() {
  const el = video.value
  if (!el) return
  if (el.paused) {
    userPaused = false
    if (!attached) attach()
    else play()
  } else {
    userPaused = true
    el.pause()
  }
}

onMounted(() => {
  // Avant : toutes les previews se chargeaient et tournaient en boucle, même hors écran.
  observer = new IntersectionObserver(([entry]) => {
    visible = entry.isIntersecting
    if (visible) {
      if (!attached && !userPaused) attach()
      else if (!userPaused) play()
    } else if (video.value && !video.value.paused) {
      video.value.pause()
    }
  }, { rootMargin: "200px 0px", threshold: 0.15 })
  observer.observe(card.value)
})

onBeforeUnmount(() => {
  // Avant : l'instance hls.js n'était jamais détruite (fuite mémoire en changeant de page)
  observer?.disconnect()
  if (hls) hls.destroy()
})
</script>

<template>
  <figure ref="card" class="card">
    <div class="media">
      <video
        ref="video"
        loop
        muted
        playsinline
        preload="none"
        disablepictureinpicture
        aria-hidden="true"
        tabindex="-1"
        :class="{ ready }"
        @loadeddata="ready = true"
        @play="paused = false"
        @pause="paused = true"
      ></video>
      <div v-if="!ready" class="placeholder" :class="{ static: failed }" aria-hidden="true"></div>

      <figcaption>
        <span v-if="promote" class="badge">À la une</span>
        <span class="title">{{ title }}</span>
      </figcaption>

      <button
        v-if="!failed"
        class="toggle"
        type="button"
        :aria-label="paused ? `Lire l'aperçu « ${title} »` : `Mettre en pause l'aperçu « ${title} »`"
        @click="togglePlayback"
      >
        <svg v-if="paused" viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path d="M5 3.5v9l7.5-4.5z" fill="currentColor"/></svg>
        <svg v-else viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path d="M4.5 3.5h2.5v9H4.5zM9 3.5h2.5v9H9z" fill="currentColor"/></svg>
      </button>
    </div>
  </figure>
</template>

<style scoped>
.card {
  margin: 0;
  background: var(--surface);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  border: solid 1px var(--border2);
  padding: 3px;
  border-radius: 21px;
  position: relative;
  transition: border-color .2s ease;
}
.card:hover { border-color: #444; }

.media {
  width: 100%;
  aspect-ratio: 16 / 9;
  background: black;
  border-radius: var(--radius-media);
  overflow: hidden;
  position: relative;
  isolation: isolate;
}

video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  opacity: 0;
  transition: opacity .4s ease;
}
video.ready { opacity: 1; }

.placeholder {
  position: absolute;
  inset: 0;
  background: linear-gradient(110deg, #0d0e10 30%, #1a1c20 50%, #0d0e10 70%) 0 0 / 250% 100%;
  animation: shimmer 1.6s linear infinite;
}
.placeholder.static { animation: none; background: radial-gradient(120% 90% at 20% 10%, #2a2d33 0%, transparent 60%), #0d0e10; }
@keyframes shimmer { to { background-position: -250% 0; } }

figcaption {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  padding: 12px 14px 32px;
  display: flex;
  align-items: center;
  gap: .5rem;
  background: linear-gradient(180deg, #000000a0 0%, #00000040 60%, transparent 100%);
  pointer-events: none;
}
.title {
  font-weight: 500;
  text-shadow: 0 1px 8px #000;
  overflow-wrap: break-word;
  word-break: break-word;
}
.badge {
  flex: none;
  padding: .25rem .55rem;
  border-radius: 999px;
  background: var(--primary);
  color: #141517;
  font-size: .72rem;
  font-weight: 700;
  font-stretch: 115%;
}

.toggle {
  position: absolute;
  right: 10px;
  bottom: 10px;
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  border: 1px solid #ffffff20;
  border-radius: 50%;
  background: #000000a0;
  -webkit-backdrop-filter: blur(6px);
  backdrop-filter: blur(6px);
  color: var(--w);
  cursor: pointer;
  opacity: 0;
  transition: opacity .2s ease, transform .3s var(--ease-out);
}
.card:hover .toggle, .toggle:focus-visible, .toggle[aria-label^="Lire"] { opacity: 1; }
.toggle:hover { transform: scale(1.08); }
@media (hover: none) { .toggle { opacity: 1; } }
</style>
