-- ============================================
-- QUIZZES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    deck_id UUID NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    question_ids UUID[] DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes for quizzes
CREATE INDEX IF NOT EXISTS idx_quizzes_deck_id ON quizzes(deck_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_created_by ON quizzes(created_by);

-- Enable RLS
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view quizzes in their decks"
    ON quizzes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = quizzes.deck_id
            AND decks.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create quizzes in their decks"
    ON quizzes FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = quizzes.deck_id
            AND decks.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can update quizzes in their decks"
    ON quizzes FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = quizzes.deck_id
            AND decks.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can delete quizzes in their decks"
    ON quizzes FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = quizzes.deck_id
            AND decks.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

-- Trigger for updated_at
CREATE TRIGGER update_quizzes_updated_at BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

