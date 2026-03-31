-- ============================================================
-- LinkedIn Content App v1 — Supabase Schema
-- Ejecutar en: Supabase > SQL Editor
-- ============================================================

-- ============================================================
-- TABLE: ideas (primero — posts la referencia)
-- Ideas diarias generadas automáticamente por IA
-- ============================================================
CREATE TABLE ideas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    angle           TEXT,                        -- problema | solución | historia | dato | debate
    suggested_hashtags TEXT[],
    trend_source    TEXT,

    date_generated  DATE NOT NULL DEFAULT CURRENT_DATE,
    status          TEXT NOT NULL DEFAULT 'new'
                    CHECK (status IN ('new','used','dismissed')),
    used_post_id    UUID                         -- FK añadida después (circular)
);

CREATE INDEX idx_ideas_date ON ideas(date_generated DESC);
CREATE INDEX idx_ideas_status ON ideas(status);


-- ============================================================
-- TABLE: posts
-- Todos los borradores y posts publicados
-- ============================================================
CREATE TABLE posts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Input original del usuario
    input_type      TEXT NOT NULL DEFAULT 'text_only'
                    CHECK (input_type IN ('text_only','text_photo','brief')),
    input_text      TEXT,

    -- Versiones generadas por IA (array de 3 objetos JSON)
    -- Estructura: [{ version, hook, body, cta, hashtags[], pinned_comment }]
    versions        JSONB,
    selected_version INTEGER DEFAULT 1
                    CHECK (selected_version BETWEEN 1 AND 3),

    -- Contenido editado por el usuario (si editó algún campo)
    final_hook      TEXT,
    final_body      TEXT,
    final_cta       TEXT,
    final_hashtags  TEXT[],
    final_pinned_comment TEXT,

    -- Imágenes
    uploaded_image_url   TEXT,                   -- Foto subida por usuario
    image_option_1       TEXT,                   -- Resultado Kie.ai opción 1
    image_option_2       TEXT,                   -- Resultado Kie.ai opción 2
    selected_image_url   TEXT,                   -- Imagen elegida
    image_task_id        TEXT,                   -- ID tarea async Kie.ai
    image_status         TEXT NOT NULL DEFAULT 'none'
                    CHECK (image_status IN ('none','pending','ready','failed')),

    -- Estado del post
    status          TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','approved','published','failed')),
    linkedin_url    TEXT,                        -- URL del post publicado (manual)
    published_at    TIMESTAMPTZ,

    -- Referencia a idea original (si el post nació de una idea)
    idea_id         UUID REFERENCES ideas(id) ON DELETE SET NULL
);

-- Trigger: actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);


-- FK circular: ideas.used_post_id → posts.id
ALTER TABLE ideas
    ADD CONSTRAINT fk_ideas_used_post
    FOREIGN KEY (used_post_id) REFERENCES posts(id) ON DELETE SET NULL;


-- ============================================================
-- TABLE: settings (fila única, id=1)
-- Configuración global de la app
-- ============================================================
CREATE TABLE settings (
    id                      INTEGER PRIMARY KEY DEFAULT 1
                            CHECK (id = 1),

    -- Kie.ai
    kieai_api_key           TEXT,

    -- LinkedIn (para v2 — publicación directa)
    linkedin_access_token   TEXT,
    linkedin_refresh_token  TEXT,
    linkedin_token_expiry   TIMESTAMPTZ,
    linkedin_person_urn     TEXT,

    -- Perfil del autor (inyectado en prompts OpenAI)
    author_name             TEXT DEFAULT 'Autor',
    author_title            TEXT DEFAULT 'Consultor de Formación B2B',
    brand_keywords          TEXT[] DEFAULT ARRAY['formación', 'aprendizaje', 'desarrollo', 'equipos'],

    -- Preferencias de generación
    ideas_per_day           INTEGER DEFAULT 5,
    sector                  TEXT DEFAULT 'formacion_empresarial_B2B',

    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar fila por defecto
INSERT INTO settings (id) VALUES (1);


-- ============================================================
-- TABLE: image_tasks
-- Seguimiento de tareas async de Kie.ai
-- ============================================================
CREATE TABLE image_tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    kieai_task_id   TEXT NOT NULL,
    task_type       TEXT NOT NULL CHECK (task_type IN ('edit','generate')),
    status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','processing','completed','failed')),
    prompt_used     TEXT,
    result_urls     JSONB,                       -- ["url1", "url2"]
    error_message   TEXT,
    poll_count      INTEGER DEFAULT 0,
    last_polled_at  TIMESTAMPTZ
);

CREATE TRIGGER image_tasks_updated_at
    BEFORE UPDATE ON image_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_image_tasks_post_id ON image_tasks(post_id);
CREATE INDEX idx_image_tasks_status ON image_tasks(status);


-- ============================================================
-- SUPABASE STORAGE: Bucket para fotos subidas por el usuario
-- Crear manualmente en Supabase > Storage > New bucket
-- Nombre: post-images
-- Acceso: Public
-- ============================================================

-- ============================================================
-- ROW LEVEL SECURITY (desactivado en v1 — app privada via nginx)
-- Activar en v2 si se añade autenticación de usuarios
-- ============================================================
-- ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE ideas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE image_tasks ENABLE ROW LEVEL SECURITY;
