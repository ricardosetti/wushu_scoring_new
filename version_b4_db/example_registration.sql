BEGIN;

-- 1. Create a Temporary Table to hold the new registration IDs
CREATE TEMP TABLE new_regs (
    reg_id INT,
    user_id INT,
    division_id INT
) ON COMMIT DROP;

-- 2. Insert Registrations
WITH new_entries AS (
    INSERT INTO public.registrations (
        user_id, tournament_id, school_id, status, created_at,
        participant_rank, height_feet, height_inches, weight, age_at_event
    )
    SELECT 
        u.id, 
        4, -- Tournament ID
        (ARRAY[8, 9, 11])[floor(random() * 3 + 1)], -- Random School (8, 9, 11)
        0, -- Status: Pending
        CURRENT_TIMESTAMP,
        
        -- Rank Logic
        CASE 
            WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) > 25 THEN 'Black Belt'
            ELSE (ARRAY['Blue Belt', 'Red Belt', 'Green Belt', 'Yellow Belt', 'White Belt'])[floor(random() * 5 + 1)]
        END,

        -- Height/Weight Logic (Approximation)
        -- Base Height (inches): 30 + (Age * 2.5) + (Gender Mod: M=2, F=0) + Random(-3 to 3)
        -- Max around 70-75 inches for adults
        (
            CASE 
                WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) >= 18 THEN 
                    (65 + (CASE WHEN u.gender = 'M' THEN 4 ELSE 0 END) + floor(random() * 6))::int
                ELSE 
                    (35 + (EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) * 2.2) + floor(random() * 5))::int
            END
        ) / 12, -- Feet

        (
            CASE 
                WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) >= 18 THEN 
                    (65 + (CASE WHEN u.gender = 'M' THEN 4 ELSE 0 END) + floor(random() * 6))::int
                ELSE 
                    (35 + (EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) * 2.2) + floor(random() * 5))::int
            END
        ) % 12, -- Inches

        -- Weight (lbs -> kg approx): (Height_in_inches * 2.5) - 80 + Random
        (
            (
                CASE 
                    WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) >= 18 THEN 
                        (65 + (CASE WHEN u.gender = 'M' THEN 4 ELSE 0 END) + floor(random() * 6))
                    ELSE 
                        (35 + (EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate)) * 2.2) + floor(random() * 5))
                END
            ) * 2.2 - 70 + floor(random() * 20)
        ) * 0.453592, -- Convert to KG

        EXTRACT(YEAR FROM age(CURRENT_DATE, u.birthdate))::int -- Age at Event

    FROM public.users u
    WHERE u.email LIKE 'user_%@example.com' -- Select only our seeded users
      AND NOT EXISTS (SELECT 1 FROM registrations r WHERE r.user_id = u.id AND r.tournament_id = 4)
    RETURNING id, user_id
)
INSERT INTO new_regs (reg_id, user_id)
SELECT id, user_id FROM new_entries;

-- 3. Link Divisions
-- Assign 1 random division to each new registration
-- We assume Tournament 4 has divisions linked in 'tournament_divisions'. 
-- If not, we pick from all 'divisions'.
INSERT INTO public.registrations_divisions (registration_id, division_id)
SELECT 
    nr.reg_id,
    (
        SELECT id FROM public.divisions 
        ORDER BY random() 
        LIMIT 1
    )
FROM new_regs nr;

COMMIT;