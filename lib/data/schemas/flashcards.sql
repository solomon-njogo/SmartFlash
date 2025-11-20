-- ============================================
-- FLASHCARDS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS flashcards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deck_id UUID NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    front_text TEXT NOT NULL,
    back_text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes for flashcards
CREATE INDEX IF NOT EXISTS idx_flashcards_deck_id ON flashcards(deck_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_created_by ON flashcards(created_by);

-- Enable RLS
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view flashcards in their decks"
    ON flashcards FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = flashcards.deck_id
            AND decks.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create flashcards in their decks"
    ON flashcards FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = flashcards.deck_id
            AND decks.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can update flashcards in their decks"
    ON flashcards FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = flashcards.deck_id
            AND decks.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can delete flashcards in their decks"
    ON flashcards FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = flashcards.deck_id
            AND decks.created_by = auth.uid()
        )
    );

-- Trigger for updated_at
CREATE TRIGGER update_flashcards_updated_at BEFORE UPDATE ON flashcards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

