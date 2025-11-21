-- ============================================
-- MIGRATION: Add course_id and material_ids to quizzes table
-- ============================================

-- Step 1: Add course_id column (nullable initially for backfill)
-- Note: courses.id is TEXT, so course_id must be TEXT to match
ALTER TABLE public.quizzes 
ADD COLUMN IF NOT EXISTS course_id TEXT;

-- Step 2: Add material_ids array column
-- Note: course_materials.id is TEXT, so material_ids must be TEXT[] to match
ALTER TABLE public.quizzes 
ADD COLUMN IF NOT EXISTS material_ids TEXT[] DEFAULT '{}'::text[];

-- Step 3: Backfill course_id from decks table
-- For quizzes that have a deck with a course_id, set the quiz's course_id
-- Note: decks.course_id is UUID, but courses.id is TEXT, so we need to cast
-- However, if decks.course_id is already TEXT in your schema, remove the cast
UPDATE public.quizzes q
SET course_id = d.course_id::TEXT
FROM public.decks d
WHERE q.deck_id = d.id
  AND d.course_id IS NOT NULL
  AND q.course_id IS NULL;

-- Step 4: Handle quizzes whose decks don't have a course_id
-- Since course_id is required, we need to handle orphaned quizzes
-- Strategy: Try to find a course for orphaned quizzes by:
--   1. Looking for the user's first course (if quiz creator has courses)
--   2. If no course found, we'll need to either delete or assign to a default

-- Step 4a: Try to assign orphaned quizzes to the creator's first course
UPDATE public.quizzes q
SET course_id = (
    SELECT c.id 
    FROM public.courses c 
    WHERE c.created_by = q.created_by 
    ORDER BY c.created_at ASC 
    LIMIT 1
)
WHERE q.course_id IS NULL
  AND EXISTS (
      SELECT 1 
      FROM public.courses c 
      WHERE c.created_by = q.created_by
  );

-- Step 4b: Check and report remaining orphaned quizzes
DO $$
DECLARE
    orphaned_count INTEGER;
    orphaned_quiz_ids TEXT[];
BEGIN
    SELECT COUNT(*), array_agg(id::text) INTO orphaned_count, orphaned_quiz_ids
    FROM public.quizzes
    WHERE course_id IS NULL;
    
    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % quizzes without course_id after backfill. Quiz IDs: %', orphaned_count, orphaned_quiz_ids;
        RAISE WARNING 'These quizzes need to be handled before setting NOT NULL constraint.';
        RAISE WARNING 'Options: 1) Delete them, 2) Assign to a default course, 3) Create courses for their creators';
    END IF;
END $$;

-- Step 4c: If you want to delete remaining orphaned quizzes, uncomment:
-- DELETE FROM public.quizzes WHERE course_id IS NULL;

-- Step 4d: If you want to assign remaining orphaned quizzes to a specific course, 
-- uncomment and update with your default course ID:
-- UPDATE public.quizzes 
-- SET course_id = 'YOUR_DEFAULT_COURSE_ID_HERE'
-- WHERE course_id IS NULL;

-- Step 5: Add foreign key constraint (only if no NULL values remain)
ALTER TABLE public.quizzes
ADD CONSTRAINT quizzes_course_id_fkey 
FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;

-- Step 6: Add index for course_id
CREATE INDEX IF NOT EXISTS idx_quizzes_course_id 
ON public.quizzes(course_id);

-- Step 7: Set course_id to NOT NULL (after backfill)
-- Note: This will fail if there are any NULL values remaining
-- Make sure all quizzes have a course_id before running this step
-- If you have orphaned quizzes, handle them in Step 4 above first

-- Check if there are any NULL values before setting NOT NULL
DO $$
DECLARE
    null_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO null_count
    FROM public.quizzes
    WHERE course_id IS NULL;
    
    IF null_count > 0 THEN
        RAISE EXCEPTION 'Cannot set course_id to NOT NULL: % quizzes still have NULL course_id. Please handle orphaned quizzes first (see Step 4).', null_count;
    END IF;
END $$;

-- Now safe to set NOT NULL
ALTER TABLE public.quizzes
ALTER COLUMN course_id SET NOT NULL;

-- Step 8: Update RLS policies to include course_id checks
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can create quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can update quizzes in their decks" ON public.quizzes;
DROP POLICY IF EXISTS "Users can delete quizzes in their decks" ON public.quizzes;

-- Create updated policies that check both deck and course ownership
CREATE POLICY "Users can view quizzes in their decks or courses"
    ON public.quizzes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.decks
            WHERE decks.id = quizzes.deck_id
            AND decks.created_by = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.courses
            WHERE courses.id = quizzes.course_id
            AND courses.created_by = auth.uid()
        )
    );

CREATE POLICY "Users can create quizzes in their decks or courses"
    ON public.quizzes FOR INSERT
    WITH CHECK (
        (
            EXISTS (
                SELECT 1 FROM public.decks
                WHERE decks.id = quizzes.deck_id
                AND decks.created_by = auth.uid()
            )
            OR EXISTS (
                SELECT 1 FROM public.courses
                WHERE courses.id = quizzes.course_id
                AND courses.created_by = auth.uid()
            )
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can update quizzes in their decks or courses"
    ON public.quizzes FOR UPDATE
    USING (
        (
            EXISTS (
                SELECT 1 FROM public.decks
                WHERE decks.id = quizzes.deck_id
                AND decks.created_by = auth.uid()
            )
            OR EXISTS (
                SELECT 1 FROM public.courses
                WHERE courses.id = quizzes.course_id
                AND courses.created_by = auth.uid()
            )
        )
        AND auth.uid() = created_by
    );

CREATE POLICY "Users can delete quizzes in their decks or courses"
    ON public.quizzes FOR DELETE
    USING (
        (
            EXISTS (
                SELECT 1 FROM public.decks
                WHERE decks.id = quizzes.deck_id
                AND decks.created_by = auth.uid()
            )
            OR EXISTS (
                SELECT 1 FROM public.courses
                WHERE courses.id = quizzes.course_id
                AND courses.created_by = auth.uid()
            )
        )
        AND auth.uid() = created_by
    );

