-- Update handle_new_user function to populate all profile fields from metadata including location
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    email, 
    name, 
    role,
    age,
    address,
    phone,
    company_name,
    technician_name,
    service_categories,
    contact_numbers,
    location_lat,
    location_lng
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'normal'),
    (NEW.raw_user_meta_data->>'age')::INTEGER,
    NEW.raw_user_meta_data->>'address',
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'company_name',
    NEW.raw_user_meta_data->>'technician_name',
    ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'service_categories', '[]'::jsonb))),
    ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'contact_numbers', '[]'::jsonb))),
    (NEW.raw_user_meta_data->>'location_lat')::DOUBLE PRECISION,
    (NEW.raw_user_meta_data->>'location_lng')::DOUBLE PRECISION
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
