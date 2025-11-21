-- ============================================
-- DECK REVIEW SCHEDULES TABLE
-- ============================================
-- This table tracks the next review date for each deck per user
-- based on the earliest due date of flashcards in the deck
CREATE TABLE IF NOT EXISTS deck_review_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deck_id UUID NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    next_review_date TIMESTAMPTZ,
    cards_due_count INTEGER NOT NULL DEFAULT 0,
    cards_learning_count INTEGER NOT NULL DEFAULT 0,
    cards_review_count INTEGER NOT NULL DEFAULT 0,
    cards_relearning_count INTEGER NOT NULL DEFAULT 0,
    last_attempt_id UUID REFERENCES deck_attempts(id) ON DELETE SET NULL,
    last_attempt_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(deck_id, user_id)
);

-- Indexes for deck_review_schedules
CREATE INDEX IF NOT EXISTS idx_deck_review_schedules_deck_id ON deck_review_schedules(deck_id);
CREATE INDEX IF NOT EXISTS idx_deck_review_schedules_user_id ON deck_review_schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_deck_review_schedules_next_review ON deck_review_schedules(next_review_date);
CREATE INDEX IF NOT EXISTS idx_deck_review_schedules_deck_user ON deck_review_schedules(deck_id, user_id);

-- Enable RLS
ALTER TABLE deck_review_schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own deck review schedules"
    ON deck_review_schedules FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own deck review schedules"
    ON deck_review_schedules FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own deck review schedules"
    ON deck_review_schedules FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own deck review schedules"
    ON deck_review_schedules FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_deck_review_schedules_updated_at BEFORE UPDATE ON deck_review_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

