-- Enable UUID extension (gen_random_uuid is built-in to PostgreSQL 13+)
-- No extension needed for gen_random_uuid()

-- =====================================================
-- Table 1: companies
-- Purpose: Stores company research data
-- =====================================================
CREATE TABLE companies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    research_data jsonb NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create indexes for companies table
CREATE INDEX idx_companies_user_id ON companies(user_id);
CREATE INDEX idx_companies_name ON companies(name);

-- =====================================================
-- Table 2: prospects
-- Purpose: Stores prospect/contact research data
-- =====================================================
CREATE TABLE prospects (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name text NOT NULL,
    title text NULL,
    research_data jsonb NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create indexes for prospects table
CREATE INDEX idx_prospects_user_id ON prospects(user_id);
CREATE INDEX idx_prospects_company_id ON prospects(company_id);
CREATE INDEX idx_prospects_name ON prospects(name);

-- =====================================================
-- Table 3: calls
-- Purpose: Stores call transcripts and analysis
-- =====================================================
CREATE TABLE calls (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    title text NULL,
    transcript text NOT NULL,
    analysis_data jsonb NULL,
    call_date timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
);

-- Create indexes for calls table
CREATE INDEX idx_calls_user_id ON calls(user_id);
CREATE INDEX idx_calls_company_id ON calls(company_id);
CREATE INDEX idx_calls_call_date ON calls(call_date);

-- =====================================================
-- Table 4: call_prospects
-- Purpose: Join table linking calls to prospects (many-to-many)
-- =====================================================
CREATE TABLE call_prospects (
    call_id uuid NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    prospect_id uuid NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (call_id, prospect_id)
);

-- Create indexes for call_prospects table
CREATE INDEX idx_call_prospects_call_id ON call_prospects(call_id);
CREATE INDEX idx_call_prospects_prospect_id ON call_prospects(prospect_id);

-- =====================================================
-- Enable Row Level Security (RLS) on all tables
-- =====================================================
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_prospects ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS Policies for companies table
-- =====================================================

-- Users can only see their own companies
CREATE POLICY "Users can view their own companies"
ON companies FOR SELECT
USING (auth.uid() = user_id);

-- Users can only insert their own companies
CREATE POLICY "Users can insert their own companies"
ON companies FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own companies
CREATE POLICY "Users can update their own companies"
ON companies FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only delete their own companies
CREATE POLICY "Users can delete their own companies"
ON companies FOR DELETE
USING (auth.uid() = user_id);

-- =====================================================
-- RLS Policies for prospects table
-- =====================================================

-- Users can only see their own prospects
CREATE POLICY "Users can view their own prospects"
ON prospects FOR SELECT
USING (auth.uid() = user_id);

-- Users can only insert their own prospects
CREATE POLICY "Users can insert their own prospects"
ON prospects FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own prospects
CREATE POLICY "Users can update their own prospects"
ON prospects FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only delete their own prospects
CREATE POLICY "Users can delete their own prospects"
ON prospects FOR DELETE
USING (auth.uid() = user_id);

-- =====================================================
-- RLS Policies for calls table
-- =====================================================

-- Users can only see their own calls
CREATE POLICY "Users can view their own calls"
ON calls FOR SELECT
USING (auth.uid() = user_id);

-- Users can only insert their own calls
CREATE POLICY "Users can insert their own calls"
ON calls FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own calls
CREATE POLICY "Users can update their own calls"
ON calls FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only delete their own calls
CREATE POLICY "Users can delete their own calls"
ON calls FOR DELETE
USING (auth.uid() = user_id);

-- =====================================================
-- RLS Policies for call_prospects table
-- =====================================================

-- Users can only see call_prospect links for their own calls
CREATE POLICY "Users can view their own call_prospect links"
ON call_prospects FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM calls
    WHERE calls.id = call_prospects.call_id
    AND calls.user_id = auth.uid()
  )
);

-- Users can only insert links for their own calls
CREATE POLICY "Users can insert their own call_prospect links"
ON call_prospects FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM calls
    WHERE calls.id = call_prospects.call_id
    AND calls.user_id = auth.uid()
  )
);

-- Users can only delete links for their own calls
CREATE POLICY "Users can delete their own call_prospect links"
ON call_prospects FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM calls
    WHERE calls.id = call_prospects.call_id
    AND calls.user_id = auth.uid()
  )
);
