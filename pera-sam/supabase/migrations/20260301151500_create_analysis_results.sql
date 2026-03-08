-- Migration to create the analysis_results table for storing sound analysis history

CREATE TABLE IF NOT EXISTS public.analysis_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  machine_id TEXT NOT NULL,
  category TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('normal', 'warning', 'abnormal')),
  confidence DOUBLE PRECISION NOT NULL,
  anomaly_score DOUBLE PRECISION NOT NULL,
  recommendation TEXT,
  details JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.analysis_results ENABLE ROW LEVEL SECURITY;

-- Policies
-- Users can view their own analysis history
CREATE POLICY "Users can view own analysis results"
ON public.analysis_results
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Users can insert their own analysis results
CREATE POLICY "Users can insert own analysis results"
ON public.analysis_results
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_analysis_results_user_id ON public.analysis_results(user_id);
