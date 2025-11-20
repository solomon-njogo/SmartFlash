-- ============================================
-- MIGRATION: Add RLS policies for authenticated users to document_texts
-- This migration adds RLS policies to allow authenticated users to manage
-- document_texts for materials they own
-- ============================================

-- Drop existing policies if they exist (except service role policy)
DROP POLICY IF EXISTS "Users can insert document texts for their materials" ON document_texts;
DROP POLICY IF EXISTS "Users can update document texts for their materials" ON document_texts;
DROP POLICY IF EXISTS "Users can view document texts for their materials" ON document_texts;

-- Allow authenticated users to insert document texts for their own materials
CREATE POLICY "Users can insert document texts for their materials"
    ON document_texts FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM course_materials cm
            WHERE cm.id = document_texts.material_id
            AND cm.uploaded_by = auth.uid()
        )
    );

-- Allow authenticated users to update document texts for their own materials
CREATE POLICY "Users can update document texts for their materials"
    ON document_texts FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM course_materials cm
            WHERE cm.id = document_texts.material_id
            AND cm.uploaded_by = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM course_materials cm
            WHERE cm.id = document_texts.material_id
            AND cm.uploaded_by = auth.uid()
        )
    );

-- Allow authenticated users to view document texts for their own materials
CREATE POLICY "Users can view document texts for their materials"
    ON document_texts FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM course_materials cm
            WHERE cm.id = document_texts.material_id
            AND cm.uploaded_by = auth.uid()
        )
    );

