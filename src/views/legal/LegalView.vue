<template>
  <MarkdownViewer
    title="Mentions légales"
    :content="mdDoc"
    :date="updated"
  />
</template>

<script setup>
  import MarkdownViewer from '@/components/MarkdownRenderer.vue'
  import mdDoc, { updated } from './docs/legal.md'
</script>
