ALTER TABLE public.tournaments
ADD COLUMN IF NOT EXISTS judges_config JSONB DEFAULT '{"A1": true, "A2": true, "B1": true, "B2": true}';


-- 1. Add Security Columns
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS verification_token VARCHAR(255),
ADD COLUMN IF NOT EXISTS reset_password_token VARCHAR(255),
ADD COLUMN IF NOT EXISTS reset_password_expires TIMESTAMP;

-- 2. Auto-verify existing users (Migration safety)
-- We assume anyone already in the system is verified so they don't get locked out.
UPDATE public.users SET is_verified = TRUE WHERE is_verified IS FALSE;