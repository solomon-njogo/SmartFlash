-- ============================================
-- MIGRATION: Add FSRS state columns to questions table
-- ============================================

-- Step 1: Add fsrs_state JSONB column to store FSRS card state
ALTER TABLE public.questions 
ADD COLUMN IF NOT EXISTS fsrs_state JSONB;

-- Step 2: Add fsrs_card_id INTEGER column for FSRS card identifier
ALTER TABLE public.questions 
ADD COLUMN IF NOT EXISTS fsrs_card_id INTEGER;

-- Step 3: Create index on fsrs_card_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_questions_fsrs_card_id ON questions(fsrs_card_id);

-- Step 4: Create index on fsrs_state->>'due' for querying due questions
CREATE INDEX IF NOT EXISTS idx_questions_fsrs_due ON questions((fsrs_state->>'due'));

-- Step 5: Create index on fsrs_state->>'state' for filtering by state
CREATE INDEX IF NOT EXISTS idx_questions_fsrs_state ON questions((fsrs_state->>'state'));

