-- Trigger function to automatically create a user profile when a new auth user is created
-- This function is idempotent and safe to run multiple times

-- ============================================================================
-- SCHEMA MIGRATION: Add profile fields to public.users if they don't exist
-- ============================================================================

-- Add date_of_birth column
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS date_of_birth DATE NULL;

-- Add gender column
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS gender TEXT NULL;

-- Add location column
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS location TEXT NULL;

-- Add profile_completed column with default false
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN NOT NULL DEFAULT FALSE;

-- ============================================================================
-- TRIGGER SETUP
-- ============================================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS public.handle_new_auth_user();

-- Create function to handle new auth user creation
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
DECLARE
  name_part TEXT;
  name_words TEXT[];
  final_name TEXT;
BEGIN
  -- Extract name from email (part before @)
  name_part := split_part(NEW.email, '@', 1);
  
  -- Split on ., _, - and capitalize each word
  name_words := string_to_array(regexp_replace(name_part, '[._-]', ' ', 'g'), ' ');
  
  -- Capitalize first letter of each word
  final_name := array_to_string(
    array(
      SELECT initcap(word)
      FROM unnest(name_words) AS word
      WHERE word != ''
    ),
    ' '
  );
  
  -- If name is empty, default to 'User'
  IF final_name = '' OR final_name IS NULL THEN
    final_name := 'User';
  END IF;

  -- Insert into public.users with safe conflict handling
  INSERT INTO public.users (
    id,
    email,
    name,
    subscription_status,
    preferences,
    duas_created,
    days_since_joined,
    profile_completed,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    final_name,
    'trial',
    '{}'::jsonb,
    0,
    0,
    FALSE,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to fire after auth user insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_auth_user();
