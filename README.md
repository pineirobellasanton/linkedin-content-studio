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

## App en vivo

**URL**: https://pineirobellasanton.github.io/linkedin-content-studio/

## Workflows n8n activos

| Workflow | ID n8n | Endpoint | Estado |
|---|---|---|---|
| [LK] Get Drafts & History | SDgpFUjZeFzvmyde | GET /lk/get-drafts | ✅ Activo |
| [LK] Generate Post Content | AixZsTjewNbSBnzA | POST /lk/generate-post | ✅ Activo |
| [LK] Update Draft | H5yJUVQK3b3myMLW | POST /lk/update-draft | ✅ Activo |
| [LK] Mark Published | SBV0JacQqCewsit7 | POST /lk/mark-published | ✅ Activo |
| [LK] Generate Images | 72ARI9FMtPt7ppXd | POST /lk/generate-images | ✅ Activo |
| [LK] Poll Image Tasks | Vdbu0ljkv1ys9vvn | Schedule 1 min | ✅ Activo |
| [LK] Generate Ideas | OPsJkWCbi2YLvGNp | Cron 7AM UTC | ✅ Activo |

## ⚠️ Pasos manuales pendientes

### 1. Variables de entorno en n8n (obligatorio)
Settings → Environment Variables → añadir:
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
APP_TOKEN=tu-token-secreto-aqui
```

### 2. Credencial OpenAI en workflows (obligatorio)
Abrir en n8n UI:
- Workflow **[LK] Generate Post Content** → nodo "Call OpenAI GPT-4o" → asignar credencial "OpenAi account 2"
- Workflow **[LK] Generate Ideas** → nodo "Call OpenAI for Ideas" → asignar credencial "OpenAi account 2"

### 3. Crear proyecto Supabase
1. Crear proyecto en supabase.com
2. SQL Editor → ejecutar `supabase/schema.sql`
3. Storage → crear bucket público `post-images`

### 4. Configurar la app
Abrir la app → pestaña **Config** → rellenar todos los campos de conexión

## Stack
- **Frontend**: HTML + Alpine.js + Tailwind CSS (zero build)
- **Backend**: n8n webhooks
- **DB**: Supabase (PostgreSQL)
- **AI texto**: OpenAI GPT-4o
- **AI imágenes**: Kie.ai
- **Hosting**: GitHub Pages
