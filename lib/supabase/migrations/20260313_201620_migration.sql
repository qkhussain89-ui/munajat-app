-- Fix A: Add first_name/last_name columns and update handle_new_user trigger
-- to read from user_metadata instead of deriving from email

-- 1. Add first_name and last_name columns if they don't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name TEXT;

-- 2. Replace the handle_new_user trigger function to read metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  first_name_val TEXT;
  last_name_val TEXT;
  final_name TEXT;
  email_name TEXT;
BEGIN
  -- Read from metadata if available
  first_name_val := NEW.raw_user_meta_data->>'first_name';
  last_name_val := NEW.raw_user_meta_data->>'last_name';

  IF first_name_val IS NOT NULL AND first_name_val != '' THEN
    -- Use metadata names
    final_name := trim(first_name_val || ' ' || coalesce(last_name_val, ''));
  ELSE
    -- Fallback: check for 'name' key in metadata
    final_name := NEW.raw_user_meta_data->>'name';
    IF final_name IS NULL OR final_name = '' THEN
      -- Last resort: derive from email
      email_name := split_part(NEW.email, '@', 1);
      email_name := replace(replace(replace(email_name, '.', ' '), '_', ' '), '-', ' ');
      final_name := initcap(email_name);
    END IF;
  END IF;

  INSERT INTO public.users (id, name, first_name, last_name, email, subscription_status, preferences, duas_created, days_since_joined, created_at, updated_at)
  VALUES (
    NEW.id,
    final_name,
    first_name_val,
    last_name_val,
    COALESCE(NEW.email, ''),
    'trial',
    '{}'::jsonb,
    0,
    0,
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

-- 3. Ensure trigger exists (drop and recreate to be safe)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
