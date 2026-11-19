-- Add column to track if user has seen inaugural du'a
ALTER TABLE users
ADD COLUMN IF NOT EXISTS has_seen_inaugural_dua BOOLEAN DEFAULT FALSE;
