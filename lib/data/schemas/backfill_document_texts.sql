-- ============================================
-- BACKFILL DOCUMENT_TEXTS - SQL HELPER
-- This script identifies materials that need parsing
-- Use this to see what will be processed by the backfill edge function
-- ============================================

-- View: Materials that need parsing
CREATE OR REPLACE VIEW materials_needing_parsing AS
SELECT 
    cm.id AS material_id,
    cm.name AS material_name,
    cm.file_type,
    cm.file_url,
    cm.uploaded_at,
    dt.parsing_status,
    dt.updated_at AS last_parsing_attempt,
    CASE 
        WHEN dt.id IS NULL THEN 'missing'
        WHEN dt.parsing_status = 'pending' THEN 'pending'
        WHEN dt.parsing_status = 'failed' THEN 'failed'
        ELSE 'completed'
    END AS status_category
FROM course_materials cm
LEFT JOIN document_texts dt ON dt.material_id = cm.id
WHERE 
    -- Only PDF, DOC, and DOCX files
    cm.file_type IN ('pdf', 'doc', 'docx')
    -- Must have a file URL
    AND cm.file_url IS NOT NULL
    AND cm.file_url != ''
    -- Either no document_texts entry, or status is pending/failed
    AND (dt.id IS NULL OR dt.parsing_status IN ('pending', 'failed'));

-- Function: Get count of materials needing parsing
CREATE OR REPLACE FUNCTION count_materials_needing_parsing()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER
        FROM materials_needing_parsing
    );
END;
$$ LANGUAGE plpgsql;

-- Function: Get summary of parsing status
CREATE OR REPLACE FUNCTION get_parsing_status_summary()
RETURNS TABLE (
    status_category TEXT,
    count BIGINT,
    file_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE 
            WHEN dt.id IS NULL THEN 'missing'
            WHEN dt.parsing_status = 'pending' THEN 'pending'
            WHEN dt.parsing_status = 'failed' THEN 'failed'
            WHEN dt.parsing_status = 'completed' THEN 'completed'
            ELSE 'unknown'
        END AS status_category,
        COUNT(*)::BIGINT AS count,
        cm.file_type
    FROM course_materials cm
    LEFT JOIN document_texts dt ON dt.material_id = cm.id
    WHERE cm.file_type IN ('pdf', 'doc', 'docx')
        AND cm.file_url IS NOT NULL
        AND cm.file_url != ''
    GROUP BY status_category, cm.file_type
    ORDER BY status_category, cm.file_type;
END;
$$ LANGUAGE plpgsql;

-- Query examples:
-- 
-- 1. See all materials that need parsing:
--    SELECT * FROM materials_needing_parsing;
--
-- 2. Count materials needing parsing:
--    SELECT count_materials_needing_parsing();
--
-- 3. Get parsing status summary:
--    SELECT * FROM get_parsing_status_summary();
--
-- 4. Create pending entries for materials without document_texts:
--    INSERT INTO document_texts (material_id, extracted_text, text_length, parsing_status, updated_at, metadata)
--    SELECT 
--        cm.id,
--        '',
--        0,
--        'pending',
--        NOW(),
--        jsonb_build_object('file_type', cm.file_type, 'file_url', cm.file_url, 'created_by_backfill', true)
--    FROM course_materials cm
--    WHERE cm.file_type IN ('pdf', 'doc', 'docx')
--        AND cm.file_url IS NOT NULL
--        AND cm.file_url != ''
--        AND NOT EXISTS (
--            SELECT 1 FROM document_texts dt WHERE dt.material_id = cm.id
--        );

