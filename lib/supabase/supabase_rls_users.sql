-- Row Level Security (RLS) for public.users
-- 
-- This script locks down the public.users table so that:
-- - Authenticated users can SELECT only their own row
-- - Authenticated users can UPDATE only their own row
-- - Client INSERT/DELETE operations are blocked
-- - The database trigger (SECURITY DEFINER) can still INSERT rows
--
-- Safe to run multiple times (idempotent where possible)

-- Enable RLS on public.users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Revoke default privileges to ensure all access is controlled by RLS policies
REVOKE ALL ON public.users FROM PUBLIC;
REVOKE ALL ON public.users FROM anon;
REVOKE ALL ON public.users FROM authenticated;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;

-- Policy A: SELECT - Users can only read their own row
CREATE POLICY "users_select_own"
ON public.users
FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Policy B: UPDATE - Users can only update their own row
CREATE POLICY "users_update_own"
ON public.users
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- No INSERT policy: Client cannot insert rows
-- No DELETE policy: Client cannot delete rows
-- The database trigger (SECURITY DEFINER) bypasses RLS and can still INSERT
