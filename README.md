# LinkedIn Content Studio

App interna para generar y publicar contenido de LinkedIn con IA para consultora B2B de formación.

## Setup rápido

### 1. Supabase
1. Crear proyecto en [supabase.com](https://supabase.com) (gratis)
2. Ir a **SQL Editor** y ejecutar el contenido de `supabase/schema.sql`
3. Ir a **Storage** > crear bucket público llamado `post-images`
4. Copiar de **Settings > API**: Project URL y `anon public` key

### 2. Variables de entorno en n8n
Ir a n8n > **Settings > Environment Variables** y añadir:
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
APP_TOKEN=pega-aqui-tu-token-secreto
```

Para generar el APP_TOKEN: usa cualquier string aleatorio largo (mínimo 32 caracteres).

### 3. Configurar el frontend (index.html)
Editar las primeras líneas del `<script>` de configuración en `index.html`:
```javascript
const CONFIG = {
  N8N_BASE: 'https://n8n-n8n-2-11.vason9.easypanel.host/webhook',
  APP_TOKEN: 'pega-aqui-el-mismo-token-que-en-n8n',
  SUPABASE_URL: 'https://xxxx.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGci...',
  STORAGE_BUCKET: 'post-images',
};
```

### 4. Configurar Settings en la app
Abrir la app > pestaña **Config** y rellenar:
- Nombre y cargo del autor
- Palabras clave de marca
- API key de [Kie.ai](https://kie.ai) (para imágenes)

---

## Workflows n8n activos

| Workflow | Webhook | Estado |
|---|---|---|
| [LK] Get Drafts & History | GET /lk/get-drafts | ✅ Activo |
| [LK] Generate Post Content | POST /lk/generate-post | ✅ Activo |
| [LK] Update Draft | POST /lk/update-draft | ✅ Activo |
| [LK] Mark Published | POST /lk/mark-published | ✅ Activo |
| [LK] Generate Images | POST /lk/generate-images | ✅ Activo |
| [LK] Generate Ideas | Cron 7AM UTC diario | ✅ Activo |

## Stack
- **Frontend**: HTML + Alpine.js + Tailwind CSS (zero build)
- **Backend**: n8n webhooks
- **DB**: Supabase (PostgreSQL)
- **AI texto**: OpenAI GPT-4o
- **AI imágenes**: Kie.ai
- **Hosting**: GitHub Pages
