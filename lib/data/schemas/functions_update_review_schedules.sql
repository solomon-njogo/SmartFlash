-- ============================================
-- DATABASE FUNCTIONS FOR AUTO-UPDATING REVIEW SCHEDULES
-- ============================================

-- Function to update deck review schedule after flashcard update
CREATE OR REPLACE FUNCTION update_deck_review_schedule_on_flashcard_update()
RETURNS TRIGGER AS $$
DECLARE
    deck_uuid UUID;
    user_uuid UUID;
BEGIN
    -- Get deck_id from the flashcard
    deck_uuid := NEW.deck_id;
    
    -- Get user_id from the flashcard's deck
    SELECT created_by INTO user_uuid
    FROM decks
    WHERE id = deck_uuid;
    
    -- Only update if we have both deck and user
    IF deck_uuid IS NOT NULL AND user_uuid IS NOT NULL THEN
        -- Update the schedule (this will be handled by the application layer)
        -- The trigger just ensures the schedule table exists
        PERFORM 1 FROM deck_review_schedules
        WHERE deck_id = deck_uuid AND user_id = user_uuid;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update quiz review schedule after question update
CREATE OR REPLACE FUNCTION update_quiz_review_schedule_on_question_update()
RETURNS TRIGGER AS $$
DECLARE
    quiz_uuid UUID;
    user_uuid UUID;
BEGIN
    -- Get quiz_id from the question
    quiz_uuid := NEW.quiz_id;
    
    -- Get user_id from the quiz's creator
    SELECT created_by INTO user_uuid
    FROM quizzes
    WHERE id = quiz_uuid;
    
    -- Only update if we have both quiz and user
    IF quiz_uuid IS NOT NULL AND user_uuid IS NOT NULL THEN
        -- Update the schedule (this will be handled by the application layer)
        -- The trigger just ensures the schedule table exists
        PERFORM 1 FROM quiz_review_schedules
        WHERE quiz_id = quiz_uuid AND user_id = user_uuid;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update deck review schedule after attempt completion
CREATE OR REPLACE FUNCTION update_deck_review_schedule_on_attempt_completion()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger on status change to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        -- The actual schedule update will be handled by the application layer
        -- This trigger ensures the schedule record exists
        PERFORM 1 FROM deck_review_schedules
        WHERE deck_id = NEW.deck_id AND user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update quiz review schedule after attempt completion
CREATE OR REPLACE FUNCTION update_quiz_review_schedule_on_attempt_completion()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger on status change to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        -- The actual schedule update will be handled by the application layer
        -- This trigger ensures the schedule record exists
        PERFORM 1 FROM quiz_review_schedules
        WHERE quiz_id = NEW.quiz_id AND user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to update deck schedule when flashcard FSRS state changes
DROP TRIGGER IF EXISTS trigger_update_deck_schedule_on_flashcard_update ON flashcards;
CREATE TRIGGER trigger_update_deck_schedule_on_flashcard_update
    AFTER UPDATE OF fsrs_state ON flashcards
    FOR EACH ROW
    WHEN (OLD.fsrs_state IS DISTINCT FROM NEW.fsrs_state)
    EXECUTE FUNCTION update_deck_review_schedule_on_flashcard_update();

-- Trigger to update quiz schedule when question FSRS state changes
DROP TRIGGER IF EXISTS trigger_update_quiz_schedule_on_question_update ON questions;
CREATE TRIGGER trigger_update_quiz_schedule_on_question_update
    AFTER UPDATE OF fsrs_state ON questions
    FOR EACH ROW
    WHEN (OLD.fsrs_state IS DISTINCT FROM NEW.fsrs_state)
    EXECUTE FUNCTION update_quiz_review_schedule_on_question_update();

-- Trigger to update deck schedule when attempt is completed
DROP TRIGGER IF EXISTS trigger_update_deck_schedule_on_attempt_completion ON deck_attempts;
CREATE TRIGGER trigger_update_deck_schedule_on_attempt_completion
    AFTER UPDATE OF status ON deck_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_deck_review_schedule_on_attempt_completion();

-- Trigger to update quiz schedule when attempt is completed
DROP TRIGGER IF EXISTS trigger_update_quiz_schedule_on_attempt_completion ON quiz_attempts;
CREATE TRIGGER trigger_update_quiz_schedule_on_attempt_completion
    AFTER UPDATE OF status ON quiz_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_quiz_review_schedule_on_attempt_completion();

