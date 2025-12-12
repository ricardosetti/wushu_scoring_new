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

BEGIN;

-- 1. Add Registration Window to Tournaments
-- 'registration_start' and 'registration_end' control when athletes can sign up
ALTER TABLE public.tournaments
ADD COLUMN IF NOT EXISTS registration_start_date DATE,
ADD COLUMN IF NOT EXISTS registration_end_date DATE;

-- 2. Add Biometrics Snapshot to Registrations
-- These fields record the athlete's stats *at the time of the event*
ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS height_feet INTEGER,
ADD COLUMN IF NOT EXISTS height_inches INTEGER,
ADD COLUMN IF NOT EXISTS weight NUMERIC(5,2),
ADD COLUMN IF NOT EXISTS age_at_event INTEGER; -- Useful for verification

-- 3. (Optional) If you want to keep 'rank' here (you already have participant_rank, so this is good)
-- Ensure participant_rank exists (it usually does from previous steps)
-- ALTER TABLE public.registrations ADD COLUMN IF NOT EXISTS participant_rank VARCHAR(50);

COMMIT;