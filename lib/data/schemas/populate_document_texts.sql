-- ============================================
-- POPULATE DOCUMENT_TEXTS FOR EXISTING MATERIALS
-- This script creates pending document_texts entries for existing
-- PDF, DOC, and DOCX materials that don't have document_texts entries yet.
-- ============================================

-- Step 1: Fix column type if material_id is UUID but should be TEXT
-- (This is safe to run even if the column is already TEXT)
DO $$
BEGIN
    -- Check if material_id is UUID type
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'document_texts' 
        AND column_name = 'material_id' 
        AND data_type = 'uuid'
    ) THEN
        -- Convert UUID column to TEXT
        ALTER TABLE document_texts 
        ALTER COLUMN material_id TYPE TEXT USING material_id::text;
        
        RAISE NOTICE 'Converted document_texts.material_id from UUID to TEXT';
    ELSE
        RAISE NOTICE 'document_texts.material_id is already TEXT or different type';
    END IF;
END $$;

-- Step 2a: Insert pending entries for materials without document_texts entries
INSERT INTO document_texts (
    material_id,
    extracted_text,
    text_length,
    parsing_status,
    updated_at,
    metadata
)
SELECT 
    cm.id AS material_id,
    '' AS extracted_text,
    0 AS text_length,
    'pending' AS parsing_status,
    NOW() AS updated_at,
    jsonb_build_object(
        'file_type', cm.file_type,
        'file_url', cm.file_url,
        'populated_at', NOW()::text,
        'needs_parsing', true
    ) AS metadata
FROM course_materials cm
WHERE 
    -- Only process PDF, DOC, and DOCX files
    cm.file_type IN ('pdf', 'doc', 'docx')
    -- Only process materials that have a file URL
    AND cm.file_url IS NOT NULL
    AND cm.file_url != ''
    -- Only insert if document_texts entry doesn't already exist
    AND NOT EXISTS (
        SELECT 1 
        FROM document_texts dt 
        WHERE dt.material_id = cm.id
    );

-- Step 2b: Reset failed parsing attempts to pending
UPDATE document_texts dt
SET 
    parsing_status = 'pending',
    updated_at = NOW(),
    metadata = COALESCE(dt.metadata, '{}'::jsonb) || jsonb_build_object(
        'populated_at', NOW()::text,
        'needs_parsing', true,
        'retry_attempt', COALESCE((dt.metadata->>'retry_attempt')::int, 0) + 1
    )
WHERE dt.parsing_status = 'failed'
    AND EXISTS (
        SELECT 1 
        FROM course_materials cm
        WHERE cm.id = dt.material_id
            AND cm.file_type IN ('pdf', 'doc', 'docx')
            AND cm.file_url IS NOT NULL
            AND cm.file_url != ''
    );

-- Step 3: Display summary of what was inserted
DO $$
DECLARE
    inserted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO inserted_count
    FROM document_texts dt
    INNER JOIN course_materials cm ON dt.material_id = cm.id
    WHERE dt.parsing_status = 'pending'
    AND dt.metadata->>'needs_parsing' = 'true';
    
    RAISE NOTICE 'Created % pending document_texts entries for existing materials', inserted_count;
    RAISE NOTICE 'Next step: Trigger parse-document Edge Function for these materials to extract text';
END $$;
