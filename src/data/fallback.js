// Données de secours, affichées UNIQUEMENT si l'API est injoignable
// (ex. preview Vercel bloquée par la protection anti-bot Cloudflare).
// Reprend le contenu visible sur dev.arsuup.fr ; pas de flux vidéo → cartes en mode "aperçu".
export const FALLBACK_VIDEOS = [
  { video_id: "fb-motion-1", type: "motion", video_title: "OBS - Starting Asset", client_id: "arsuup", client_name: "Arsuup", timestamp: "", promote: 1 },
  { video_id: "fb-edit-1", type: "editing", video_title: "Manhunt MAIS on partage TOUS le même inventaire", client_id: "frogteam12", client_name: "Frogteam12", timestamp: "5 septembre", promote: 0 },
  { video_id: "fb-edit-2", type: "editing", video_title: "Minecraft mais les blocs sont randoms", client_id: "frogteam12", client_name: "Frogteam12", timestamp: "1785974400", promote: 0 },
  { video_id: "fb-edit-3", type: "editing", video_title: "Minecraft mais on obtient les blocs qu'on regarde...", client_id: "frogteam12", client_name: "Frogteam12", timestamp: "1783296000", promote: 0 },
  { video_id: "fb-tt-1", type: "tiktok", video_title: "Wivryx - Tiktok 1", client_id: "wivryx", client_name: "Wivryx", timestamp: "1777075200", promote: 0 },
  { video_id: "fb-tt-2", type: "tiktok", video_title: "Devine les blocs #3 ft @ShinyyOff", client_id: "frogteam12", client_name: "Frogteam12", timestamp: "1779494400", promote: 0 },
  { video_id: "fb-tt-3", type: "tiktok", video_title: "Bloc Télépathie #3 ft @ShinyyOff", client_id: "frogteam12", client_name: "Frogteam12", timestamp: "1778371200", promote: 0 },
]
