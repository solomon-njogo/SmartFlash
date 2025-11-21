-- ============================================
-- QUIZ REVIEW SCHEDULES TABLE
-- ============================================
-- This table tracks the next review date for each quiz per user
-- based on the earliest due date of questions in the quiz
CREATE TABLE IF NOT EXISTS quiz_review_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    next_review_date TIMESTAMPTZ,
    questions_due_count INTEGER NOT NULL DEFAULT 0,
    questions_learning_count INTEGER NOT NULL DEFAULT 0,
    questions_review_count INTEGER NOT NULL DEFAULT 0,
    questions_relearning_count INTEGER NOT NULL DEFAULT 0,
    last_attempt_id UUID REFERENCES quiz_attempts(id) ON DELETE SET NULL,
    last_attempt_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(quiz_id, user_id)
);

-- Indexes for quiz_review_schedules
CREATE INDEX IF NOT EXISTS idx_quiz_review_schedules_quiz_id ON quiz_review_schedules(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_review_schedules_user_id ON quiz_review_schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_review_schedules_next_review ON quiz_review_schedules(next_review_date);
CREATE INDEX IF NOT EXISTS idx_quiz_review_schedules_quiz_user ON quiz_review_schedules(quiz_id, user_id);

-- Enable RLS
ALTER TABLE quiz_review_schedules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own quiz review schedules"
    ON quiz_review_schedules FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own quiz review schedules"
    ON quiz_review_schedules FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quiz review schedules"
    ON quiz_review_schedules FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own quiz review schedules"
    ON quiz_review_schedules FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_quiz_review_schedules_updated_at BEFORE UPDATE ON quiz_review_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

