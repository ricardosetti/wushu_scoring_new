ALTER TABLE public.tournaments
ADD COLUMN IF NOT EXISTS judges_config JSONB DEFAULT '{"A1": true, "A2": true, "B1": true, "B2": true}';