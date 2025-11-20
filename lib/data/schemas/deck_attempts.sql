-- ============================================
-- DECK ATTEMPTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS deck_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deck_id UUID NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    total_cards INTEGER NOT NULL DEFAULT 0,
    cards_studied INTEGER NOT NULL DEFAULT 0,
    cards_again INTEGER NOT NULL DEFAULT 0,
    cards_hard INTEGER NOT NULL DEFAULT 0,
    cards_good INTEGER NOT NULL DEFAULT 0,
    cards_easy INTEGER NOT NULL DEFAULT 0,
    total_time_seconds INTEGER NOT NULL DEFAULT 0,
    attempt_number INTEGER NOT NULL DEFAULT 1,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for deck_attempts
CREATE INDEX IF NOT EXISTS idx_deck_attempts_deck_id ON deck_attempts(deck_id);
CREATE INDEX IF NOT EXISTS idx_deck_attempts_user_id ON deck_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_deck_attempts_status ON deck_attempts(status);
CREATE INDEX IF NOT EXISTS idx_deck_attempts_deck_user ON deck_attempts(deck_id, user_id);

-- Enable RLS
ALTER TABLE deck_attempts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own deck attempts"
    ON deck_attempts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own deck attempts"
    ON deck_attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own deck attempts"
    ON deck_attempts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own deck attempts"
    ON deck_attempts FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_deck_attempts_updated_at BEFORE UPDATE ON deck_attempts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

