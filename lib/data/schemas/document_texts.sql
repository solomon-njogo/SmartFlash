-- ============================================
-- DOCUMENT_TEXTS TABLE
-- Stores parsed text from uploaded documents
-- ============================================
CREATE TABLE IF NOT EXISTS document_texts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id TEXT NOT NULL,
    extracted_text TEXT NOT NULL,
    text_length INTEGER NOT NULL,
    word_count INTEGER DEFAULT 0,
    parsing_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (parsing_status IN ('pending', 'completed', 'failed')),
    parsed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB
);

-- Unique constraint: one document_text per material
CREATE UNIQUE INDEX IF NOT EXISTS idx_document_texts_material_id_unique ON document_texts(material_id);

-- Indexes for document_texts
CREATE INDEX IF NOT EXISTS idx_document_texts_material_id ON document_texts(material_id);
CREATE INDEX IF NOT EXISTS idx_document_texts_parsing_status ON document_texts(parsing_status);

-- Enable RLS
ALTER TABLE document_texts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow service role full access
CREATE POLICY "Service role can manage document texts"
    ON document_texts FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

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

