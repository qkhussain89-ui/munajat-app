-- Add first_name and last_name columns if they don't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name TEXT;

-- Update handle_new_user trigger to use metadata names
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
DECLARE
  first_name_val TEXT;
  last_name_val TEXT;
  final_name TEXT;
  name_part TEXT;
  name_words TEXT[];
BEGIN
  first_name_val := NEW.raw_user_meta_data->>'first_name';
  last_name_val := NEW.raw_user_meta_data->>'last_name';

  IF first_name_val IS NOT NULL AND first_name_val != '' THEN
    final_name := trim(first_name_val || ' ' || coalesce(last_name_val, ''));
  ELSE
    name_part := split_part(NEW.email, '@', 1);
    name_words := string_to_array(
      regexp_replace(name_part, '[._-]', ' ', 'g'), ' '
    );
    final_name := array_to_string(ARRAY(
      SELECT initcap(w) FROM unnest(name_words) AS w
    ), ' ');
  END IF;

  INSERT INTO public.users (id, email, name, first_name, last_name)
  VALUES (
    NEW.id,
    NEW.email,
    final_name,
    coalesce(first_name_val, ''),
    coalesce(last_name_val, '')
  )
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
