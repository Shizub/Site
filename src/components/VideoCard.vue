<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue"
import ClientBadge from "./ClientBadge.vue"
import { API_ORIGIN, API_URL } from "@/utils/constants"
import { detectPlatform, formatDate, getYouTubeThumbnails, isHls, throughProxy, toISODate } from "@/utils/format"

const props = defineProps({
  orientation: { type: String, default: "landscape" }, // "landscape" | "portrait"
  client_id: String,
  client_name: String, // données de secours uniquement
  timeline_link: String,
  youtube_link: String,
  video_title: String,
  video_link: String,
  timestamp: [String, Number],
  promote: Boolean,
})

const video = ref(null)
const started = ref(false)
const loadingVideo = ref(false)
const playError = ref(false)
let hls = null

const platform = computed(() => detectPlatform(props.youtube_link))
const isDisabled = computed(() => !props.youtube_link || !platform.value)
const linktext = computed(() => (platform.value ? `Regarder sur ${platform.value}` : "Vidéo indisponible"))
const hasTimeline = computed(() => !!props.timeline_link)
const src = computed(() => throughProxy(props.video_link, API_ORIGIN, API_URL))
const canPlay = computed(() => !!src.value)
const dateLabel = computed(() => formatDate(props.timestamp))
const dateISO = computed(() => toISODate(props.timestamp))

/* ---- Miniature : on essaie maxres → hq720 → hqdefault, puis un visuel neutre ----
   (avant : hqdefault = 4:3 avec bandes noires, et les liens /shorts/ ou youtu.be?si= n'avaient pas de miniature) */
const thumbs = computed(() => getYouTubeThumbnails(props.youtube_link))
const thumbIndex = ref(0)
const thumbnail = computed(() => thumbs.value[thumbIndex.value] || null)
function onThumbLoad(e) {
  // YouTube renvoie une image grise 120x90 quand une résolution n'existe pas
  if (e.target.naturalWidth <= 120) thumbIndex.value++
}
function onThumbError() {
  thumbIndex.value++
}

/* ---- Lecture : on ne charge hls.js (≈ 500 Ko) qu'au premier clic ---- */
async function start() {
  if (!canPlay.value || loadingVideo.value) return
  loadingVideo.value = true
  playError.value = false
  const el = video.value

  try {
    if (isHls(src.value) && !el.canPlayType("application/vnd.apple.mpegurl")) {
      const { default: Hls } = await import("hls.js")
      if (!Hls.isSupported()) throw new Error("HLS non supporté")
      hls = new Hls({ capLevelToPlayerSize: true })
      hls.loadSource(src.value)
      hls.attachMedia(el)
      hls.on(Hls.Events.ERROR, (_, data) => {
        if (data.fatal) {
          playError.value = true
          started.value = false
          hls.destroy()
          hls = null
        }
      })
      await new Promise((resolve) => hls.once(Hls.Events.MANIFEST_PARSED, resolve))
    } else {
      el.src = src.value
    }
    started.value = true
    await el.play()
  } catch (err) {
    // play() peut être refusé (autoplay policy) : les contrôles natifs restent dispo
    if (err?.name !== "NotAllowedError" && err?.name !== "AbortError") {
      console.error("Lecture impossible :", err)
      playError.value = true
      started.value = false
    }
  } finally {
    loadingVideo.value = false
  }
}

/* Une seule vidéo à la fois : lancer une carte met les autres en pause */
function onPlay() {
  window.dispatchEvent(new CustomEvent("arsuup:play", { detail: video.value }))
}
function onOtherPlay(e) {
  if (e.detail !== video.value && video.value && !video.value.paused) video.value.pause()
}
onMounted(() => window.addEventListener("arsuup:play", onOtherPlay))

onBeforeUnmount(() => {
  window.removeEventListener("arsuup:play", onOtherPlay)
  if (hls) hls.destroy()
})

watch(started, (v) => {
  if (v) requestAnimationFrame(() => video.value?.focus({ preventScroll: true }))
})
</script>

<template>
  <article class="card" :class="orientation">
    <div class="media">
      <video
        ref="video"
        :class="{ hidden: !started }"
        :poster="thumbnail || undefined"
        :aria-label="video_title"
        playsinline
        controls
        preload="none"
        @play="onPlay"
      ></video>

      <div v-if="!started" class="cover">
        <img
          v-if="thumbnail"
          class="thumb"
          :src="thumbnail"
          :alt="''"
          loading="lazy"
          decoding="async"
          @load="onThumbLoad"
          @error="onThumbError"
        >
        <div v-else class="thumb placeholder" aria-hidden="true">
          <span>{{ video_title }}</span>
        </div>

        <span v-if="promote" class="badge">À la une</span>

        <button
          v-if="canPlay"
          class="play"
          type="button"
          :aria-label="`Lire la vidéo « ${video_title} »`"
          :aria-busy="loadingVideo"
          @click="start"
        >
          <span class="play-icon" :class="{ spinning: loadingVideo }" aria-hidden="true">
            <svg v-if="!loadingVideo" viewBox="0 0 24 24" width="22" height="22"><path d="M8 5.5v13a1 1 0 0 0 1.5.86l11-6.5a1 1 0 0 0 0-1.72l-11-6.5A1 1 0 0 0 8 5.5Z" fill="currentColor"/></svg>
          </span>
        </button>
        <p v-if="playError" class="error" role="status">Lecture impossible ici — essaie le lien ci-dessous.</p>
      </div>
    </div>

    <div class="footer">
      <div class="topinfos">
        <ClientBadge :client-id="client_id" :preset-name="client_name" />
        <time v-if="dateLabel" class="date" :datetime="dateISO">{{ dateLabel }}</time>
      </div>

      <h3 class="title">{{ video_title }}</h3>

      <div class="cta">
        <a v-if="hasTimeline" class="timelinebtn" :href="timeline_link" target="_blank" rel="noopener noreferrer">Voir la timeline</a>
        <a v-if="!isDisabled" class="btn" :href="youtube_link" target="_blank" rel="noopener noreferrer">
          {{ linktext }}
          <svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path d="M5 11 11 5M6 5h5v5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
          <span class="sr-only">(nouvel onglet)</span>
        </a>
        <span v-else class="btn btn-disabled" aria-disabled="true">{{ linktext }}</span>
      </div>
    </div>
  </article>
</template>

<style scoped>
.card {
  background: var(--surface);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  border: solid 1px var(--border2);
  padding: 10px;
  border-radius: var(--radius-card);
  transition: border-color .2s ease, transform .5s var(--ease-out);
}
.card:hover { border-color: #444; }

.media {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  background: black;
  border-radius: var(--radius-media);
  overflow: hidden;
  isolation: isolate;
}
.portrait .media { aspect-ratio: 9 / 16; }

video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  background: black;
}
video.hidden { visibility: hidden; }
.portrait video { object-fit: contain; }

.cover {
  position: absolute;
  inset: 0;
}
.thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform .6s var(--ease-out), filter .3s ease;
}
.card:hover .thumb { transform: scale(1.03); }
.placeholder {
  display: grid;
  place-items: center;
  padding: 1.5rem;
  text-align: center;
  background:
    radial-gradient(120% 90% at 20% 10%, #2a2d33 0%, transparent 60%),
    radial-gradient(90% 80% at 90% 100%, #1d2024 0%, transparent 60%),
    #0d0e10;
  color: #ffffff55;
  font-weight: 700;
  font-stretch: 115%;
  font-size: 1.05rem;
  line-height: 1.25;
}

.badge {
  position: absolute;
  top: 10px;
  left: 10px;
  padding: .3rem .6rem;
  border-radius: 999px;
  background: var(--primary);
  color: #141517;
  font-size: .75rem;
  font-weight: 700;
  font-stretch: 115%;
  letter-spacing: .02em;
}

.play {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  border: 0;
  padding: 0;
  background: linear-gradient(180deg, transparent 55%, #00000066 100%);
  cursor: pointer;
  border-radius: inherit;
}
.play:focus-visible { outline-offset: -4px; border-radius: var(--radius-media); }
.play-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  color: var(--b);
  background: color-mix(in srgb, var(--w) 92%, transparent);
  box-shadow: 0 8px 30px -6px #000000aa;
  transform: scale(.92);
  transition: transform .5s var(--ease-out), background .2s ease;
}
.play-icon svg { margin-left: 3px; }
.play:hover .play-icon, .play:focus-visible .play-icon { transform: scale(1.04); background: var(--w); }
.spinning {
  border: 3px solid #ffffff30;
  border-top-color: var(--b);
  animation: spin .8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.error {
  position: absolute;
  left: 10px; right: 10px; bottom: 10px;
  margin: 0;
  padding: .5rem .7rem;
  border-radius: 10px;
  background: #000000cc;
  font-size: .85rem;
}

.footer {
  padding: 12px 8px 6px;
  display: flex;
  flex-direction: column;
  gap: .7rem;
  flex: 1;
}

.topinfos {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: .75rem;
  min-width: 0;
}

.date {
  color: var(--textMuted);
  font-size: .9rem;
  font-weight: 400;
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}

.title {
  margin: 0;
  font-size: 1rem;
  font-weight: 500;
  line-height: 1.35;
  text-wrap: pretty;
}

.cta {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  flex-wrap: wrap;
  gap: .5rem 1rem;
  margin-top: auto;
}

.timelinebtn {
  color: var(--textSecondary);
  font-size: .95rem;
  text-decoration-line: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 4px;
  transition: color .1s;
}
.timelinebtn:hover { color: var(--w); }

.btn {
  display: inline-flex;
  align-items: center;
  gap: .45rem;
  background: black;
  padding: .6rem .9rem;
  border-radius: 10px;
  color: var(--w);
  text-decoration: none;
  transition: transform .5s var(--ease-out), background .2s ease;
}
.btn svg { transition: transform .5s var(--ease-out); }
.btn:hover { transform: scale(1.05); background: #000; }
.btn:hover svg { transform: translate(2px, -2px); }
.btn:active { transform: scale(.98); }
.btn-disabled, .btn-disabled:hover {
  background: transparent;
  border: 1px dashed var(--border2);
  color: var(--textMuted);
  transform: none;
  cursor: not-allowed;
}

.portrait .cta .btn { flex: 1; justify-content: center; }

@media (hover: none) {
  .card:hover .thumb { transform: none; }
}
</style>
