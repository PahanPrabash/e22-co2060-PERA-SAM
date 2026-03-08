-- Migration to create the repair_requests table
CREATE TABLE IF NOT EXISTS public.repair_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  analysis_id UUID REFERENCES public.analysis_results(id) ON DELETE SET NULL,
  machine_type TEXT NOT NULL,
  brand TEXT,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'completed', 'declined')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.repair_requests ENABLE ROW LEVEL SECURITY;

-- Policies for repair_requests
-- Users (requesters) can manage their own requests
CREATE POLICY "Users can manage own requests"
ON public.repair_requests
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Companies can view and update requests assigned to them
CREATE POLICY "Companies can manage received requests"
ON public.repair_requests
FOR ALL
TO authenticated
USING (company_id = auth.uid())
WITH CHECK (company_id = auth.uid());

-- Allow companies to view the profiles of people who requested service from them
CREATE POLICY "Companies can view requester profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  id IN (
    SELECT user_id 
    FROM public.repair_requests 
    WHERE company_id = auth.uid()
  )
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_repair_requests_company_id ON public.repair_requests(company_id);
CREATE INDEX IF NOT EXISTS idx_repair_requests_user_id ON public.repair_requests(user_id);
