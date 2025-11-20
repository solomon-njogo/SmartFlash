-- ============================================
-- QUESTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) NOT NULL DEFAULT 'multipleChoice' CHECK (question_type IN ('multipleChoice', 'trueFalse', 'fillInTheBlank', 'matching', 'shortAnswer')),
    options TEXT[] DEFAULT '{}',
    correct_answers TEXT[] NOT NULL DEFAULT '{}',
    explanation TEXT,
    "order" INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes for questions
CREATE INDEX IF NOT EXISTS idx_questions_quiz_id ON questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_questions_order ON questions(quiz_id, "order");

-- Enable RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view questions in their quizzes"
    ON questions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM quizzes
            JOIN decks ON decks.id = quizzes.deck_id
            WHERE quizzes.id = questions.quiz_id
            AND decks.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create questions in their quizzes"
    ON questions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM quizzes
            JOIN decks ON decks.id = quizzes.deck_id
            WHERE quizzes.id = questions.quiz_id
            AND decks.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can update questions in their quizzes"
    ON questions FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM quizzes
            JOIN decks ON decks.id = quizzes.deck_id
            WHERE quizzes.id = questions.quiz_id
            AND decks.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can delete questions in their quizzes"
    ON questions FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM quizzes
            JOIN decks ON decks.id = quizzes.deck_id
            WHERE quizzes.id = questions.quiz_id
            AND decks.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

-- Trigger for updated_at
CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

