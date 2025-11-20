-- ============================================
-- MIGRATION: Remove deck_id from quizzes table
-- ============================================
-- This migration removes the incorrect deck_id reference from quizzes.
-- Quizzes should only reference courses and materials, not decks.

-- Step 1: Drop existing RLS policies that reference deck_id
DROP POLICY IF EXISTS "Users can view quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can create quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can update quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can delete quizzes in their decks" ON public.quizzes;

-- Step 2: Drop the foreign key constraint on deck_id
ALTER TABLE public.quizzes 
DROP CONSTRAINT IF EXISTS quizzes_deck_id_fkey;

-- Step 3: Drop the index on deck_id
DROP INDEX IF EXISTS public.idx_quizzes_deck_id;

-- Step 4: Drop the deck_id column
ALTER TABLE public.quizzes 
DROP COLUMN IF EXISTS deck_id;

-- Step 5: Ensure course_id exists and is NOT NULL
-- (This should already be done by migrate_quizzes_add_course_materials.sql)
-- But we'll verify and set it if needed
DO $$
BEGIN
    -- Check if course_id column exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'quizzes' 
        AND column_name = 'course_id'
    ) THEN
        ALTER TABLE public.quizzes ADD COLUMN course_id TEXT;
    END IF;

    -- Check if there are any quizzes without course_id
    IF EXISTS (SELECT 1 FROM public.quizzes WHERE course_id IS NULL) THEN
        RAISE WARNING 'Found quizzes without course_id. These need to be handled before setting NOT NULL.';
        RAISE WARNING 'Please backfill course_id for all quizzes before running this migration.';
    ELSE
        -- Set NOT NULL constraint if no NULL values exist
        ALTER TABLE public.quizzes ALTER COLUMN course_id SET NOT NULL;
        
        -- Add foreign key constraint if it doesn't exist
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_schema = 'public' 
            AND table_name = 'quizzes' 
            AND constraint_name = 'quizzes_course_id_fkey'
        ) THEN
            ALTER TABLE public.quizzes
            ADD CONSTRAINT quizzes_course_id_fkey 
            FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;
        END IF;
    END IF;
END $$;

-- Step 6: Ensure material_ids column exists
ALTER TABLE public.quizzes 
ADD COLUMN IF NOT EXISTS material_ids TEXT[] DEFAULT '{}'::text[];

-- Step 7: Create new RLS policies that check course ownership for quizzes
CREATE POLICY "Users can view quizzes in their courses"
    ON public.quizzes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.courses
            WHERE courses.id = quizzes.course_id
            AND courses.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create quizzes in their courses"
    ON public.quizzes FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.courses
            WHERE courses.id = quizzes.course_id
            AND courses.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can update quizzes in their courses"
    ON public.quizzes FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.courses
            WHERE courses.id = quizzes.course_id
            AND courses.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can delete quizzes in their courses"
    ON public.quizzes FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.courses
            WHERE courses.id = quizzes.course_id
            AND courses.created_by = auth.uid()
        )
        AND auth.uid() = created_by
    );

-- Step 8: Update RLS policies for questions table to use course ownership
-- Drop existing policies that reference decks
DROP POLICY IF EXISTS "Users can view questions in their quizzes" ON public.questions;
DROP POLICY IF EXISTS "Users can create questions in their quizzes" ON public.questions;
DROP POLICY IF EXISTS "Users can update questions in their quizzes" ON public.questions;
DROP POLICY IF EXISTS "Users can delete questions in their quizzes" ON public.questions;

-- Create new policies that check course ownership through quizzes
CREATE POLICY "Users can view questions in their quizzes"
    ON public.questions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.quizzes
            JOIN public.courses ON courses.id = quizzes.course_id
            WHERE quizzes.id = questions.quiz_id
            AND courses.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create questions in their quizzes"
    ON public.questions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.quizzes
            JOIN public.courses ON courses.id = quizzes.course_id
            WHERE quizzes.id = questions.quiz_id
            AND courses.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can update questions in their quizzes"
    ON public.questions FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.quizzes
            JOIN public.courses ON courses.id = quizzes.course_id
            WHERE quizzes.id = questions.quiz_id
            AND courses.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can delete questions in their quizzes"
    ON public.questions FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.quizzes
            JOIN public.courses ON courses.id = quizzes.course_id
            WHERE quizzes.id = questions.quiz_id
            AND courses.created_by = auth.uid()
            AND quizzes.created_by = auth.uid()
        )
    );

