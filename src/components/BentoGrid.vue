<script setup>
import { API_URL } from "@/utils/constants"
import { ref, onMounted, computed } from "vue"
import VideoCard from "./VideoCard.vue"
import VideoPreviewCard from "./VideoPreviewCard.vue"
import SectionDivider from "./SectionDivider.vue"
import { toTime } from "@/utils/format"
import { FALLBACK_VIDEOS } from "@/data/fallback"

const typeConfig = {
  motion: { title: "Motion Design", layout: "preview" },
  editing: { title: "Montage", layout: "landscape" },
  tiktok: { title: "Tiktoks", layout: "portrait" },
}

const videos = ref([])
const loading = ref(true)
const error = ref(null)
const usingFallback = ref(false)

async function fetchVideos() {
  loading.value = true
  error.value = null
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 8000)
  try {
    const res = await fetch(`${API_URL}/videos/list`, { signal: controller.signal })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const data = await res.json()
    if (!Array.isArray(data)) throw new Error("Réponse inattendue de l'API")
    videos.value = data
    usingFallback.value = false
  } catch (err) {
    error.value = err
    console.error("Erreur lors du chargement des vidéos :", err)
    // Plutôt qu'une page vide avec "Erreur lors du chargement de la page." :
    // on affiche les projets connus en mode aperçu + un bouton pour réessayer.
    videos.value = FALLBACK_VIDEOS
    usingFallback.value = true
  } finally {
    clearTimeout(timeout)
    loading.value = false
  }
}

onMounted(fetchVideos)

function sortVideos(items) {
  return [...items].sort((a, b) => {
    const promoteDiff = Number(b.promote || 0) - Number(a.promote || 0)
    if (promoteDiff !== 0) return promoteDiff
    return toTime(b.timestamp) - toTime(a.timestamp)
  })
}

const sections = computed(() => {
  return Object.entries(typeConfig)
    .map(([type, config]) => ({
      type,
      ...config,
      items: sortVideos(videos.value.filter((v) => v.type === type)),
    }))
    .filter((section) => section.items.length > 0)
})
</script>

<template>
  <!-- Squelettes pendant le chargement (avant : texte "Chargement...") -->
  <div v-if="loading" class="skeletons" aria-busy="true" aria-live="polite">
    <span class="sr-only">Chargement des projets…</span>
    <div class="sk-divider"></div>
    <div class="grid landscape">
      <div class="sk-card"></div>
    </div>
    <div class="sk-divider"></div>
    <div class="grid landscape">
      <div class="sk-card tall"></div>
      <div class="sk-card tall"></div>
    </div>
  </div>

  <template v-else>
    <div v-if="usingFallback" class="notice" role="status">
      <span>Les vidéos n'ont pas pu être chargées. Aperçu des derniers projets affiché.</span>
      <button type="button" @click="fetchVideos">Réessayer</button>
    </div>

    <p v-if="!sections.length" class="empty">Aucun projet à afficher pour le moment.</p>

    <section v-for="section in sections" :key="section.type" :aria-labelledby="`section-${section.type}`">
      <SectionDivider :id="`section-${section.type}`" :title="section.title" :count="section.items.length" />

      <div class="grid" :class="section.layout">
        <template v-if="section.layout === 'preview'">
          <VideoPreviewCard
            v-for="video in section.items"
            :key="video.video_id"
            :stream="video.video_link"
            :title="video.video_title"
            :promote="Boolean(Number(video.promote))"
          />
        </template>
        <template v-else>
          <VideoCard
            v-for="video in section.items"
            :key="video.video_id"
            :orientation="section.layout"
            :client_id="video.client_id"
            :client_name="video.client_name"
            :timeline_link="video.timeline_link"
            :youtube_link="video.youtube_link"
            :video_title="video.video_title"
            :video_link="video.video_link"
            :timestamp="video.timestamp"
            :promote="Boolean(Number(video.promote))"
          />
        </template>
      </div>
    </section>
  </template>
</template>

<style scoped>
.grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  margin: 0 auto 20px;
}
/* Les TikToks sont verticaux : 3 colonnes en 9:16 au lieu d'être rognés en 16:9 */
.grid.portrait {
  grid-template-columns: repeat(3, minmax(0, 1fr));
  background: #101013;
  border-radius: 28px;
  outline: 5px solid #101013;
}

@media (max-width: 1100px) {
  .grid.landscape, .grid.preview { grid-template-columns: minmax(0, 1fr); }
}
@media (max-width: 1100px) and (min-width: 901px) {
  .grid.portrait { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}
@media (max-width: 900px) and (min-width: 641px) {
  .grid.landscape, .grid.preview { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}
/* Mobile : carrousel horizontal à snap pour les TikToks */
@media (max-width: 640px) {
  .grid.portrait {
    display: flex;
    overflow-x: auto;
    scroll-snap-type: x mandatory;
    scroll-padding-inline: 2px;
    margin-inline: calc(var(--gutter) * -1);
    padding-inline: var(--gutter);
    outline: none;
    background: none;
    border-radius: 0;
    scrollbar-width: none;
  }
  .grid.portrait::-webkit-scrollbar { display: none; }
  .grid.portrait > * {
    flex: 0 0 72%;
    scroll-snap-align: start;
  }
}

.notice {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin: 8px 0 4px;
  padding: .75rem 1rem;
  border: 1px solid #e5db2040;
  background: #e5db200d;
  border-radius: 14px;
  color: var(--textSecondary);
  font-size: .92rem;
}
.notice button {
  border: 1px solid var(--border2);
  background: var(--surface);
  color: var(--w);
  padding: .45rem .8rem;
  border-radius: 8px;
  cursor: pointer;
}
.notice button:hover { background: #000; }

.empty { color: var(--textSecondary); text-align: center; padding: 3rem 0; }

.sk-divider {
  height: 1px;
  margin: 36px 0 24px;
  background: var(--border2);
}
.sk-card {
  aspect-ratio: 16 / 9;
  border-radius: 21px;
  border: 1px solid var(--border2);
  background: linear-gradient(110deg, var(--surface) 30%, #1a1c20 50%, var(--surface) 70%) 0 0 / 250% 100%;
  animation: shimmer 1.6s linear infinite;
}
.sk-card.tall { aspect-ratio: 16 / 13; border-radius: 28px; }
@keyframes shimmer { to { background-position: -250% 0; } }
</style>
