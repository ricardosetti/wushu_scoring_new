BEGIN;

-- 1. BRACKETS Table
-- Stores the high-level container for a division's competition structure
CREATE TABLE IF NOT EXISTS public.brackets (
    id SERIAL PRIMARY KEY,
    tournament_id INTEGER REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE,
    division_id INTEGER REFERENCES public.divisions(id) ON DELETE CASCADE,
    bracket_type VARCHAR(50) NOT NULL, -- 'single_elimination', 'round_robin', 'pool'
    name VARCHAR(100), -- e.g. "Main Draw", "Pool A"
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'active', 'completed'
    settings JSONB, -- Store config like { "third_place_match": true }
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tournament_id, division_id, name) -- Prevent duplicate named brackets in same div
);

-- 2. MATCHES Table
-- Stores individual nodes in the bracket tree
CREATE TABLE IF NOT EXISTS public.matches (
    id SERIAL PRIMARY KEY,
    bracket_id INTEGER REFERENCES public.brackets(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL, -- 1 = Finals, 2 = Semis, etc. OR 1 = Round 1, 2 = Round 2
    match_number INTEGER NOT NULL, -- Order within the round
    participant1_id INTEGER REFERENCES public.participants(id), -- Nullable (bye or TBD)
    participant2_id INTEGER REFERENCES public.participants(id), -- Nullable
    winner_id INTEGER REFERENCES public.participants(id),
    next_match_id INTEGER REFERENCES public.matches(id), -- Pointer to where the winner goes
    status VARCHAR(50) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed'
    scores JSONB, -- Store detailed scores if needed here, or link to published_scores
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMIT;