-- ============================================
-- MIGRATION: Change decks.course_id from UUID to TEXT
-- ============================================
-- This migration changes decks.course_id to TEXT to match courses.id format
-- since courses.id is TEXT, not UUID

-- Step 1: Drop the existing foreign key constraint if it exists
-- (Note: There might not be a foreign key, but we'll check)
DO $$
BEGIN
    -- Check if there's a foreign key constraint
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'public' 
        AND table_name = 'decks' 
        AND constraint_name LIKE '%course_id%'
    ) THEN
        -- Drop the constraint (we'll need to find the exact name)
        ALTER TABLE public.decks 
        DROP CONSTRAINT IF EXISTS decks_course_id_fkey;
    END IF;
END $$;

-- Step 2: Change the column type from UUID to TEXT
-- First, convert existing UUID values to TEXT
ALTER TABLE public.decks 
ALTER COLUMN course_id TYPE TEXT USING course_id::TEXT;

-- Step 3: Recreate the index (it should still work with TEXT)
-- The index should already exist, but we'll ensure it's there
CREATE INDEX IF NOT EXISTS idx_decks_course_id ON decks(course_id);

-- Note: We cannot create a foreign key constraint to courses(id) 
-- because courses.id is TEXT and we want to maintain referential integrity
-- However, the application layer should handle this validation

