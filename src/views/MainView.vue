<script setup>
import { ref } from "vue"
import BentoGrid from "@/components/BentoGrid.vue"
import { CONTACT_MAIL } from "@/utils/constants"

// Avant : <a> sans href + addEventListener → ni focusables au clavier, ni clic-molette, ni curseur main.
const softwares = [
  { short: "Pr", name: "Adobe Premiere Pro", href: "https://www.adobe.com/fr/products/premiere.html", tone: "video" },
  { short: "Ae", name: "Adobe After Effects", href: "https://www.adobe.com/fr/products/aftereffects.html", tone: "video" },
  { short: "Au", name: "Adobe Audition", href: "https://www.adobe.com/fr/products/audition.html", tone: "video" },
  { short: "Ps", name: "Adobe Photoshop", href: "https://www.adobe.com/fr/products/photoshop.html", tone: "photo" },
]

const inspirations = [
  { name: "Sameztwitch", href: "https://www.instagram.com/sameztwitch/" },
  { name: "Théo Meunier", href: "https://www.instagram.com/le__meunier/" },
  { name: "Laupok", href: "https://www.youtube.com/@Laupok" },
]

// Copier l'adresse mail en un clic (pratique sur desktop sans client mail configuré)
const copied = ref(false)
let copiedTimer = null
async function copyMail() {
  try {
    await navigator.clipboard.writeText(CONTACT_MAIL)
  } catch {
    const ta = document.createElement("textarea")
    ta.value = CONTACT_MAIL
    document.body.appendChild(ta)
    ta.select()
    document.execCommand("copy")
    ta.remove()
  }
  copied.value = true
  clearTimeout(copiedTimer)
  copiedTimer = setTimeout(() => (copied.value = false), 1800)
}
</script>

<template>
  <div class="layout">

    <aside class="sidebar" aria-label="À propos d'Arsuup">
      <div class="identity">
        <img class="avatar" src="/i/pfp.jpg" alt="Avatar d'Arsuup" width="180" height="180" fetchpriority="high" />
        <div>
          <h1>Arsuup</h1>
          <p class="role">Monteur vidéo &amp; motion designer</p>
        </div>
      </div>

      <div class="block">
        <h2 class="biotx">Inspirations :</h2>
        <ul class="links">
          <li v-for="i in inspirations" :key="i.name">
            <a :href="i.href" target="_blank" rel="noopener noreferrer">{{ i.name }}<span class="sr-only"> (nouvel onglet)</span></a>
          </li>
        </ul>
      </div>

      <div class="block">
        <h2 class="biotx">Logiciels :</h2>
        <ul class="softwares">
          <li v-for="s in softwares" :key="s.short">
            <a
              :href="s.href"
              :class="s.tone"
              :title="s.name"
              :aria-label="s.name"
              target="_blank"
              rel="noopener noreferrer"
            >{{ s.short }}</a>
          </li>
        </ul>
      </div>

      <div id="contact" class="block contact">
        <h2 class="biotx">Me contacter :</h2>
        <ul class="links">
          <li class="mail-row">
            <a :href="`mailto:${CONTACT_MAIL}`">Mail : {{ CONTACT_MAIL }}</a>
            <button type="button" class="copy" :aria-label="copied ? 'Adresse copiée' : 'Copier l\'adresse mail'" @click="copyMail">
              <svg v-if="!copied" viewBox="0 0 16 16" width="15" height="15" aria-hidden="true"><rect x="5" y="5" width="8.5" height="8.5" rx="2" fill="none" stroke="currentColor" stroke-width="1.4"/><path d="M10.5 5V3.5a1.5 1.5 0 0 0-1.5-1.5H4A1.5 1.5 0 0 0 2.5 3.5V9A1.5 1.5 0 0 0 4 10.5h1" fill="none" stroke="currentColor" stroke-width="1.4"/></svg>
              <svg v-else viewBox="0 0 16 16" width="15" height="15" aria-hidden="true"><path d="m3.5 8.5 3 3 6-7" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </button>
            <span class="copied" :class="{ show: copied }" role="status">{{ copied ? 'Copié !' : '' }}</span>
          </li>
          <li>
            <a href="https://l.arsuup.fr/insta" target="_blank" rel="noopener noreferrer">Insta : @arsuup_<span class="sr-only"> (nouvel onglet)</span></a>
          </li>
        </ul>
      </div>
    </aside>

    <div class="content">
      <BentoGrid />
    </div>

  </div>
</template>

<style scoped>
.layout {
  display: grid;
  grid-template-columns: 330px minmax(0, 1fr);
  width: 100%;
  max-width: var(--usercontent);
  padding-inline: var(--gutter);
}

.sidebar {
  position: sticky;
  top: var(--header-h);
  align-self: start;
  max-height: calc(100dvh - var(--header-h));
  overflow-y: auto;
  scrollbar-width: none;
  padding: 24px 24px 32px 0;
  border-right: 1px solid #222;
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.sidebar::-webkit-scrollbar { display: none; }

.identity {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.avatar {
  width: 60%;
  height: auto;
  aspect-ratio: 1;
  border-radius: 16px;
  object-fit: cover;
  user-select: none;
  pointer-events: none;
  background: #000;
}
h1 {
  margin: 0;
  font-size: 1.6rem;
  font-weight: 700;
  font-stretch: 120%;
  letter-spacing: -.01em;
}
.role {
  margin: .35rem 0 0;
  color: var(--textSecondary);
  font-size: .95rem;
}

ul { list-style: none; margin: 0; padding: 0; }

.biotx {
  margin: 0 0 10px;
  font-size: 1rem;
  font-weight: 600;
  font-stretch: 125%;
}
.links {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
}
.links a {
  display: inline-block;
  color: var(--w);
  opacity: 0.75;
  text-decoration: none;
  padding: 6px 10px;
  background: var(--chip);
  border-radius: 6px;
  transition: opacity .1s, background .1s;
}
.links a:hover { opacity: 1; background: #000; }

.contact {
  padding: 12px 10px 10px;
  background: var(--surface-2);
  width: max-content;
  max-width: 100%;
  border-radius: 10px;
  border: solid 1px var(--border2);
}
.mail-row {
  display: flex;
  align-items: center;
  gap: 6px;
  position: relative;
}
.copy {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border: 0;
  border-radius: 6px;
  background: var(--chip);
  color: var(--textSecondary);
  cursor: pointer;
  transition: color .1s, background .1s;
}
.copy:hover { color: var(--w); background: #000; }
.copied {
  position: absolute;
  left: calc(100% + 8px);
  white-space: nowrap;
  font-size: .8rem;
  color: var(--primary);
  opacity: 0;
  transform: translateX(-4px);
  transition: opacity .2s, transform .3s var(--ease-out);
}
.copied.show { opacity: 1; transform: none; }

.softwares {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.softwares a {
  display: inline-block;
  color: #9999ff;
  font-weight: 800;
  padding: 6px 10px;
  background: #00005b;
  border-radius: 10px;
  text-decoration: none;
  transition: scale .3s var(--ease-out), box-shadow .2s;
  user-select: none;
}
.softwares a.photo {
  background: #001e36;
  color: #31a8ff;
}
.softwares a:hover { scale: 1.1; box-shadow: 0 6px 18px -6px currentColor; }

.content {
  padding: 20px 0 20px 20px;
  min-width: 0;
}

/* ---- Tablette / mobile : sidebar compacte au-dessus du contenu ---- */
@media (max-width: 900px) {
  .layout { grid-template-columns: minmax(0, 1fr); }
  .sidebar {
    position: relative;
    top: 0;
    max-height: none;
    overflow: visible;
    padding: 24px 0;
    border-right: none;
    border-bottom: 1px solid var(--border2);
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 20px 24px;
  }
  .identity {
    grid-column: 1 / -1;
    flex-direction: row;
    align-items: center;
    gap: 16px;
  }
  .avatar { width: 88px; }
  .links { flex-direction: row; flex-wrap: wrap; }
  .contact { width: auto; }
  .content { padding: 8px 0 20px; }
}
@media (max-width: 480px) {
  .contact .links { flex-direction: column; }
  .copied { position: static; }
}
</style>
