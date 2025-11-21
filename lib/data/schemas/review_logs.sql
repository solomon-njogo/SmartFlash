-- ============================================
-- REVIEW LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS review_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL,
    card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('flashcard', 'question')),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating VARCHAR(10) NOT NULL CHECK (rating IN ('again', 'hard', 'good', 'easy')),
    review_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scheduled_days INTEGER NOT NULL DEFAULT 0,
    elapsed_days INTEGER NOT NULL DEFAULT 0,
    state VARCHAR(20) NOT NULL CHECK (state IN ('learning', 'review', 'relearning')),
    card_state VARCHAR(20) NOT NULL CHECK (card_state IN ('learning', 'review', 'relearning')),
    response_time DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    stability DECIMAL(10,4),
    difficulty DECIMAL(10,4),
    retrievability DECIMAL(10,4),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for review_logs
CREATE INDEX IF NOT EXISTS idx_review_logs_card_id ON review_logs(card_id);
CREATE INDEX IF NOT EXISTS idx_review_logs_card_type ON review_logs(card_type);
CREATE INDEX IF NOT EXISTS idx_review_logs_user_id ON review_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_review_logs_card_user ON review_logs(card_id, user_id);
CREATE INDEX IF NOT EXISTS idx_review_logs_review_datetime ON review_logs(review_datetime);
CREATE INDEX IF NOT EXISTS idx_review_logs_card_type_user ON review_logs(card_type, user_id);

-- Enable RLS
ALTER TABLE review_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own review logs"
    ON review_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own review logs"
    ON review_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own review logs"
    ON review_logs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own review logs"
    ON review_logs FOR DELETE
    USING (auth.uid() = user_id);

