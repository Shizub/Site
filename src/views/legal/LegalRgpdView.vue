<template>
  <MarkdownViewer
    title="Politique de confidentialité"
    :content="mdDoc"
    :date="updated"
  />
</template>

<script setup>
  import MarkdownViewer from '@/components/MarkdownRenderer.vue'
  import mdDoc, { updated } from './docs/rgpd.md'
</script>
