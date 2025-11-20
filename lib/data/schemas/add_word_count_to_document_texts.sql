-- ============================================
-- MIGRATION: Add word_count column to document_texts
-- This migration adds the word_count column if it doesn't exist
-- ============================================

-- Add word_count column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'document_texts' 
        AND column_name = 'word_count'
    ) THEN
        ALTER TABLE document_texts 
        ADD COLUMN word_count INTEGER DEFAULT 0;
        
        RAISE NOTICE 'Added word_count column to document_texts table';
    ELSE
        RAISE NOTICE 'word_count column already exists in document_texts table';
    END IF;
END $$;

