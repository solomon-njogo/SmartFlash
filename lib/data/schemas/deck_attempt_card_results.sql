-- ============================================
-- DECK ATTEMPT CARD RESULTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS deck_attempt_card_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES deck_attempts(id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
    rating VARCHAR(10) NOT NULL CHECK (rating IN ('again', 'hard', 'good', 'easy')),
    time_spent_seconds INTEGER NOT NULL DEFAULT 0,
    answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "order" INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for deck_attempt_card_results
CREATE INDEX IF NOT EXISTS idx_deck_attempt_card_results_attempt_id ON deck_attempt_card_results(attempt_id);
CREATE INDEX IF NOT EXISTS idx_deck_attempt_card_results_flashcard_id ON deck_attempt_card_results(flashcard_id);
CREATE INDEX IF NOT EXISTS idx_deck_attempt_card_results_attempt_order ON deck_attempt_card_results(attempt_id, "order");

-- Enable RLS
ALTER TABLE deck_attempt_card_results ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view card results for their attempts"
    ON deck_attempt_card_results FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM deck_attempts
            WHERE deck_attempts.id = deck_attempt_card_results.attempt_id
            AND deck_attempts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create card results for their attempts"
    ON deck_attempt_card_results FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM deck_attempts
            WHERE deck_attempts.id = deck_attempt_card_results.attempt_id
            AND deck_attempts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update card results for their attempts"
    ON deck_attempt_card_results FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM deck_attempts
            WHERE deck_attempts.id = deck_attempt_card_results.attempt_id
            AND deck_attempts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete card results for their attempts"
    ON deck_attempt_card_results FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM deck_attempts
            WHERE deck_attempts.id = deck_attempt_card_results.attempt_id
            AND deck_attempts.user_id = auth.uid()
        )
    );

