-- Transaction start
BEGIN;

-- 1. Create 250 Male Users
INSERT INTO public.users (
    username, email, password, role, 
    first_name, last_name, gender, birthdate,
    street, city, state, country, zip_code,
    phone, emergency_contact_name, emergency_contact_phone,
    is_verified, created_at
)
SELECT 
    'user_m_' || id || '@example.com', -- Username
    'user_m_' || id || '@example.com', -- Email
    '$2b$10$MIoeaTAIDPPp4V38e0Da5e.QnTN5D.7y5WwPfbavTseM0YMbuNjVC', -- Hash for "123456"
    'participant',
    'MaleUser' || id, -- First Name
    'Test',           -- Last Name
    'M',              -- Gender
    -- Random date between 4 and 14 years ago
    CURRENT_DATE - (floor(random() * (14 * 365 - 4 * 365) + 4 * 365) || ' days')::interval,
    '123 Wushu Way', 'Martial City', 'NJ', 'USA', '07001', -- Address
    '555-0100', 'Parent Name', '555-9999', -- Contacts
    TRUE, -- Verified
    CURRENT_TIMESTAMP
FROM generate_series(1, 250) as id;

-- 2. Create 250 Female Users
INSERT INTO public.users (
    username, email, password, role, 
    first_name, last_name, gender, birthdate,
    street, city, state, country, zip_code,
    phone, emergency_contact_name, emergency_contact_phone,
    is_verified, created_at
)
SELECT 
    'user_f_' || id || '@example.com',
    'user_f_' || id || '@example.com',
    '$2b$10$MIoeaTAIDPPp4V38e0Da5e.QnTN5D.7y5WwPfbavTseM0YMbuNjVC',
    'participant',
    'FemaleUser' || id,
    'Test',
    'F',
    CURRENT_DATE - (floor(random() * (14 * 365 - 4 * 365) + 4 * 365) || ' days')::interval,
    '123 Wushu Way', 'Martial City', 'NJ', 'USA', '07001',
    '555-0100', 'Parent Name', '555-9999',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(251, 500) as id;

COMMIT;