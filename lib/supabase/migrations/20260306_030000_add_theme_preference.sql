-- Add theme preference to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS theme_preference TEXT DEFAULT 'dark' CHECK (theme_preference IN ('dark', 'light', 'auto'));
