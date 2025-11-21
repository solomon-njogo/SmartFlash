-- ============================================
-- MIGRATION: Add FSRS state columns to flashcards table
-- ============================================

-- Step 1: Add fsrs_state JSONB column to store FSRS card state
ALTER TABLE public.flashcards 
ADD COLUMN IF NOT EXISTS fsrs_state JSONB;

-- Step 2: Add fsrs_card_id INTEGER column for FSRS card identifier
ALTER TABLE public.flashcards 
ADD COLUMN IF NOT EXISTS fsrs_card_id INTEGER;

-- Step 3: Create index on fsrs_card_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_flashcards_fsrs_card_id ON flashcards(fsrs_card_id);

-- Step 4: Create index on fsrs_state->>'due' for querying due cards
CREATE INDEX IF NOT EXISTS idx_flashcards_fsrs_due ON flashcards((fsrs_state->>'due'));

-- Step 5: Create index on fsrs_state->>'state' for filtering by state
CREATE INDEX IF NOT EXISTS idx_flashcards_fsrs_state ON flashcards((fsrs_state->>'state'));

