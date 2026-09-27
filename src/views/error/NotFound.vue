<script setup>
import { useRoute } from 'vue-router'
const route = useRoute()
</script>

<template>
  <div class="main">
    <div class="panel">
      <div class="top">
        <h1>404</h1>
        <p>Cette page n'existe pas.</p>
        <code class="path">{{ route.fullPath }}</code>
      </div>
      <div class="bottom">
        <router-link to="/">Retour à l'accueil</router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
.main {
  flex: 1;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem var(--gutter);
}

.panel {
  background: var(--surface);
  padding: 2rem;
  border: solid 1px var(--border2);
  width: min(22rem, 100%);
  border-radius: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 2rem;
}
.top { display: flex; flex-direction: column; gap: .5rem; }
.bottom {
  justify-content: end;
  display: flex;
}

h1 {
  margin: 0;
  font-size: 4rem;
  font-weight: 900;
  font-stretch: 120%;
  line-height: 1;
}
p {
  color: var(--textSecondary);
  margin: 0;
  font-size: 1.2rem;
}
.path {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: .85rem;
  color: var(--textMuted);
  overflow-wrap: anywhere;
}
a {
  background: black;
  color: var(--w);
  padding: 0.6rem 1.2rem;
  font-size: 1.1rem;
  border-radius: 10px;
  transition: transform .5s var(--ease-out);
  text-decoration: none;
}
a:hover { transform: scale(1.05); }
</style>
