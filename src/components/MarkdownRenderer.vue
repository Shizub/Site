<script setup>
  defineProps({
    title: {
      type: String,
      required: true
    },
    content: {
      type: [Object, Function],
      required: true
    },
    date: {
      type: String,
      default: ''
    }
  })
</script>

<template>
  <div class="page">
    <article>
      <router-link to="/" class="back">
        <svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path d="M10 3.5 5.5 8l4.5 4.5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Retour au portfolio
      </router-link>
      <div class="infos">
        <h1>{{ title }}</h1>
        <p v-if="date">Dernière révision : {{ date }}</p>
      </div>
      <component :is="content.default || content" />
    </article>
  </div>
</template>

<style scoped>
  .page {
    width: 100%;
    padding-inline: var(--gutter);
    display: flex;
    justify-content: center;
  }
  article {
    width: 100%;
    max-width: 760px;
    display: flex;
    flex-direction: column;
    padding: 2.5rem 0 4rem;
  }
  .back {
    align-self: flex-start;
    display: inline-flex;
    align-items: center;
    gap: .35rem;
    color: var(--textSecondary);
    text-decoration: none;
    font-size: .9rem;
    padding: .4rem .6rem .4rem .3rem;
    margin-left: -.3rem;
    border-radius: 8px;
    transition: color .1s, background .1s;
  }
  .back:hover { color: var(--w); background: var(--surface); }
  .infos {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin: 1.5rem 0 1.5rem;
  }
  .infos h1 {
    font-size: clamp(1.5rem, 3vw, 2rem);
    font-stretch: 120%;
    color: var(--text);
    margin: 0;
  }
  .infos p {
    font-size: 0.9rem;
    color: var(--textMuted);
    margin: 0;
  }

  .markdown-body {
    background: var(--surface);
    border: solid 1px var(--border);
    color: var(--text);
    padding: .5rem clamp(1.1rem, 4vw, 2rem) 1.5rem;
    border-radius: 16px;
    line-height: 1.6;
  }
  :deep(a) {
    color: var(--primary);
    text-decoration: underline;
    text-decoration-color: #e5db2060;
    text-underline-offset: 3px;
  }
  :deep(a:hover) { text-decoration-color: var(--primary); }
  :deep(h2) {
    font-size: 1.15rem;
    font-stretch: 125%;
    margin: 1.8rem 0 .6rem;
  }
  :deep(p), :deep(li) {
    color: var(--textSecondary);
  }
  :deep(li + li) { margin-top: .3rem; }
  :deep(strong) { color: var(--text); font-weight: 600; }
  :deep(code) {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: .88em;
    background: #000;
    padding: .1rem .35rem;
    border-radius: 5px;
    color: var(--w);
  }
  :deep(table) {
    border-radius: 12px;
    overflow: hidden;
    border-collapse: separate;
    border-spacing: 0;
    border: solid 1px var(--border);
  }
  :deep(th), :deep(td) {
    padding: .4rem .6rem;
    background: var(--surface);
    border-bottom: solid 1px var(--border);
    border-right: solid 1px var(--border);
  }
  :deep(th):last-child, :deep(td):last-child { border-right: none; }
  :deep(tr):last-child td { border-bottom: none; }
</style>
