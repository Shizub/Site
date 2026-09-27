<script setup>
defineProps({
  title: String,
  count: Number,
  id: String,
})
</script>

<template>
  <h2 :id="id" class="divider">
    <span>{{ title }}<span v-if="count" class="count" :aria-label="`(${count} vidéos)`">{{ count }}</span></span>
  </h2>
</template>

<style scoped>
.divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 28px 0 16px;
  color: var(--textSecondary);
  font-size: 1rem;
  font-weight: 500;
  scroll-margin-top: calc(var(--header-h) + 16px);
}
.divider:first-child { margin-top: 8px; }

.divider::before,
.divider::after {
  content: "";
  flex: 1;
  height: 1px;
  background: var(--border2);
}

.divider > span {
  display: inline-flex;
  align-items: center;
  gap: .5rem;
  white-space: nowrap;
  font-stretch: 125%;
}
.count {
  display: inline-grid;
  place-items: center;
  min-width: 1.4rem;
  height: 1.4rem;
  padding: 0 .35rem;
  border-radius: 999px;
  background: var(--surface);
  border: 1px solid var(--border2);
  font-size: .72rem;
  font-stretch: 100%;
  color: var(--textSecondary);
  font-variant-numeric: tabular-nums;
}
</style>
