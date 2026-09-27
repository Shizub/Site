<script setup>
import { computed, ref } from "vue"
import { useClientInfo } from "@/utils/clientInfos"

const props = defineProps({
  clientId: String,
  presetName: String,
})

const { clientName, clientLink, clientAvatar, status } = useClientInfo(props.clientId, { name: props.presetName })

// Avant : une image cassée affichait un "?" gris. Maintenant : initiale sur fond coloré.
const avatarFailed = ref(false)
const initial = computed(() => (clientName.value || props.clientId || "?").trim().charAt(0).toUpperCase())
const hue = computed(() => {
  const s = clientName.value || props.clientId || ""
  let h = 0
  for (const c of s) h = (h * 31 + c.charCodeAt(0)) % 360
  return h
})
</script>

<template>
  <component
    :is="clientLink ? 'a' : 'span'"
    class="client"
    :href="clientLink || undefined"
    :target="clientLink ? '_blank' : undefined"
    :rel="clientLink ? 'noopener noreferrer' : undefined"
  >
    <span class="avatar" :style="{ '--hue': hue }">
      <img
        v-if="!avatarFailed"
        :src="clientAvatar"
        alt=""
        width="32"
        height="32"
        loading="lazy"
        decoding="async"
        @error="avatarFailed = true"
      >
      <span v-else aria-hidden="true">{{ initial }}</span>
    </span>
    <span v-if="status === 'loading'" class="name skeleton" aria-hidden="true"></span>
    <span v-else-if="clientName" class="name">@{{ clientName }}</span>
    <span v-else class="name muted">Client</span>
    <span v-if="clientLink" class="sr-only">(nouvel onglet)</span>
  </component>
</template>

<style scoped>
.client {
  display: inline-flex;
  align-items: center;
  gap: .5rem;
  color: inherit;
  text-decoration: none;
  min-width: 0;
  border-radius: 999px;
  padding-right: .4rem;
}
a.client:hover .name { text-decoration: underline; text-underline-offset: 3px; text-decoration-thickness: 1px; }
.avatar {
  flex: none;
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  overflow: hidden;
  display: grid;
  place-items: center;
  background: hsl(var(--hue) 35% 22%);
  color: hsl(var(--hue) 70% 80%);
  font-weight: 700;
  font-size: .9rem;
}
.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  user-select: none;
  pointer-events: none;
}
.name {
  font-size: .95rem;
  font-stretch: 110%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.muted { color: var(--textSecondary); }
.skeleton {
  display: inline-block;
  width: 7rem;
  height: .9rem;
  border-radius: 6px;
  background: linear-gradient(90deg, #1c1e21 0%, #26292d 50%, #1c1e21 100%) 0 0 / 200% 100%;
  animation: shimmer 1.2s linear infinite;
}
@keyframes shimmer { to { background-position: -200% 0; } }
</style>
