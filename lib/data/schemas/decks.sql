-- ============================================
-- DECKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS decks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
    course_id UUID
);

-- Indexes for decks
CREATE INDEX IF NOT EXISTS idx_decks_created_by ON decks(created_by);
CREATE INDEX IF NOT EXISTS idx_decks_course_id ON decks(course_id);

-- Enable RLS
ALTER TABLE decks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own decks"
    ON decks FOR SELECT
    USING (auth.uid() = created_by);

CREATE POLICY "Users can create their own decks"
    ON decks FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own decks"
    ON decks FOR UPDATE
    USING (auth.uid() = created_by);

CREATE POLICY "Users can delete their own decks"
    ON decks FOR DELETE
    USING (auth.uid() = created_by);

-- Trigger for updated_at
CREATE TRIGGER update_decks_updated_at BEFORE UPDATE ON decks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

