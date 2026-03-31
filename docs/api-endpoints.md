# API Endpoints — LinkedIn Content App

## Base URL
```
https://n8n-n8n-2-11.vason9.easypanel.host/webhook
```

## Autenticación
Todas las llamadas deben incluir el header:
```
X-App-Token: TU_TOKEN_SECRETO
```
Generar con: `openssl rand -hex 32`

---

## Endpoints

### POST /lk/generate-post
Genera 3 versiones de post LinkedIn a partir del input del usuario. Crea un borrador en Supabase.

**Request body:**
```json
{
  "input_type": "text_only",       // "text_only" | "text_photo" | "brief"
  "input_text": "Quiero hablar sobre cómo el microlearning mejora la retención...",
  "uploaded_image_url": null        // URL de Supabase Storage si subió foto
}
```

**Response:**
```json
{
  "success": true,
  "post_id": "uuid-aqui",
  "versions": [
    {
      "version": 1,
      "hook": "El 70% de lo aprendido se olvida en 24 horas.",
      "body": "...",
      "cta": "¿Qué técnica usas tú para mejorar la retención en tus equipos?",
      "hashtags": ["Formacion", "Microlearning", "RRHH", "AprendizajeB2B"],
      "pinned_comment": "..."
    },
    { "version": 2, ... },
    { "version": 3, ... }
  ]
}
```

---

### GET /lk/get-drafts
Devuelve lista de posts/borradores + ideas de hoy.

**Query params:**
- `status` (optional): `draft` | `approved` | `published` | `all` (default: `all`)
- `page` (optional): número de página (default: 1)
- `limit` (optional): resultados por página (default: 20, max: 50)

**Ejemplo:** `GET /lk/get-drafts?status=draft&page=1&limit=20`

**Response:**
```json
{
  "posts": [...],
  "ideas": [...],
  "total": 45,
  "page": 1,
  "limit": 20
}
```

---

### POST /lk/update-draft
Actualiza cualquier campo de un borrador. Se usa también para cambiar el estado.

**Request body:**
```json
{
  "post_id": "uuid-aqui",
  "updates": {
    "selected_version": 2,
    "final_hook": "Texto editado del hook...",
    "final_body": "...",
    "final_cta": "...",
    "final_hashtags": ["Formacion", "B2B"],
    "final_pinned_comment": "...",
    "selected_image_url": "https://...",
    "status": "approved"
  }
}
```

**Campos permitidos en `updates`:**
- `selected_version` (1-3)
- `final_hook`, `final_body`, `final_cta`
- `final_hashtags` (array de strings sin #)
- `final_pinned_comment`
- `selected_image_url`
- `status` (`draft` | `approved`)

---

### POST /lk/mark-published
Marca un post como publicado (después de publicar manualmente en LinkedIn).

**Request body:**
```json
{
  "post_id": "uuid-aqui",
  "linkedin_url": "https://www.linkedin.com/posts/..."  // opcional
}
```

**Response:**
```json
{
  "success": true,
  "post": { ...post actualizado }
}
```

---

### POST /lk/generate-images
Envía una tarea de generación/edición de imagen a Kie.ai (async).
La imagen se procesa en background; el frontend hace polling para ver cuando está lista.

**Request body:**
```json
{
  "post_id": "uuid-aqui",
  "task_type": "generate",          // "generate" | "edit"
  "prompt": "Profesional en sala de formación corporativa, luz cálida natural...",
  "uploaded_image_url": null         // requerido si task_type = "edit"
}
```

**Response (inmediata):**
```json
{
  "success": true,
  "task_id": "kieai-task-id",
  "image_status": "pending"
}
```

El post se actualiza automáticamente cuando Kie.ai termina (polling interno cada 1 min).
El frontend puede verificar el estado haciendo GET /lk/get-drafts filtrando por post_id.

---

### GET /lk/poll-images
Dispara el polling manual de tareas Kie.ai pendientes. 
El polling también ocurre automáticamente cada 1 minuto via Schedule Trigger en n8n.

**Response:**
```json
{
  "processed": 2,
  "completed": 1,
  "still_pending": 1
}
```

---

## Credenciales necesarias

| Credencial | Dónde obtener | Dónde configurar |
|---|---|---|
| Supabase URL | Supabase project → Settings → API | Variable de entorno n8n: `SUPABASE_URL` |
| Supabase Anon Key | Supabase project → Settings → API | Variable de entorno n8n: `SUPABASE_ANON_KEY` |
| OpenAI API Key | Ya configurado en n8n | Credencial existente |
| Kie.ai API Key | kie.ai → Dashboard → API Keys | Tabla `settings.kieai_api_key` en Supabase |
| App Token | `openssl rand -hex 32` | En index.html (variable `APP_TOKEN`) + validado en n8n |
| Supabase URL (frontend) | Igual que arriba | En index.html (variable `SUPABASE_URL`) |
| Supabase Anon Key (frontend) | Igual que arriba | En index.html (variable `SUPABASE_ANON_KEY`) |

## Variables a configurar en n8n
Ir a n8n → Settings → Environment Variables:
```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
APP_TOKEN=tu-token-generado-con-openssl
```
