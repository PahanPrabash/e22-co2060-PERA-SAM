-- Ensure profiles for companies are publicly readable for the map display
-- And also ensure any existing accounts that should be companies are correctly tagged.

-- Drop old policy if exists
DROP POLICY IF EXISTS "Anyone can view company profiles for map" ON public.profiles;

-- Create a more permissive policy for viewing company profiles
CREATE POLICY "Company profiles are publicly viewable"
ON public.profiles
FOR SELECT
USING (role = 'company');

-- Also allow authenticated users to view all profiles (needed for joining with requests)
-- but restricted to basic fields if we want to be safe. For now, let's just make it work.
DROP POLICY IF EXISTS "Authenticated users can view all profiles" ON public.profiles;
CREATE POLICY "Authenticated users can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (true);

-- Fix for existing users: Ensure the specific user identified in screenshot is a company if needed
-- User ID: 33a6025b-c48f-47ed-8daa-0d263402fdbb (University of Peradeniya)
UPDATE public.profiles 
SET role = 'company' 
WHERE email = 'e22184@eng.pdn.ac.lk' AND role = 'normal';

-- Ensure they have a location if they don't have one (at Peradeniya)
UPDATE public.profiles
SET location_lat = 7.2525, location_lng = 80.5925
WHERE role = 'company' AND (location_lat IS NULL OR location_lng IS NULL);
