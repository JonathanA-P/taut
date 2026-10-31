-- ==============================================================================
-- TAUT — PostgreSQL Database Migration Draft: Initial Schema & RLS
-- Stage 01: Project Foundation & Security Architecture
-- Author: Alfredo Jonathan Purba (Team Lead & Backend Architect)
-- Team: Mardua Holong (INCEPTION 2026 Hackathon)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. HELPER FUNCTIONS
-- Automatically update updated_at timestamps on row modifications
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 3. PROFILES TABLE
-- Extends Supabase auth.users with public profile metadata
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ------------------------------------------------------------------------------
-- 4. FRIENDSHIPS TABLE
-- Bi-directional friendship relation with explicit state machine
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),

  -- Prevent a user from friending themselves
  CONSTRAINT check_no_self_friendship CHECK (requester_id <> addressee_id)
);

-- Ensure a pair of users cannot have duplicate friendship records regardless of order
CREATE UNIQUE INDEX IF NOT EXISTS idx_friendships_unique_pair
  ON public.friendships (LEAST(requester_id, addressee_id), GREATEST(requester_id, addressee_id));

CREATE INDEX IF NOT EXISTS idx_friendships_requester ON public.friendships(requester_id);
CREATE INDEX IF NOT EXISTS idx_friendships_addressee ON public.friendships(addressee_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON public.friendships(status);

CREATE TRIGGER set_friendships_updated_at
  BEFORE UPDATE ON public.friendships
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ------------------------------------------------------------------------------
-- 5. FRIEND INVITES TABLE
-- Token-based friend invitations (QR code / invite link)
-- Tokens are stored as cryptographic hashes (SHA-256) to prevent token leaks
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.friend_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inviter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_friend_invites_token_hash ON public.friend_invites(token_hash);
CREATE INDEX IF NOT EXISTS idx_friend_invites_inviter ON public.friend_invites(inviter_id);

-- ------------------------------------------------------------------------------
-- 6. LOCATION SHARES TABLE
-- Live location sharing sessions between verified friends
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.location_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  accuracy_m DOUBLE PRECISION,
  started_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,

  CONSTRAINT check_no_self_sharing CHECK (owner_id <> recipient_id),
  CONSTRAINT check_valid_latitude CHECK (latitude >= -90.0 AND latitude <= 90.0),
  CONSTRAINT check_valid_longitude CHECK (longitude >= -180.0 AND longitude <= 180.0)
);

CREATE INDEX IF NOT EXISTS idx_location_shares_owner ON public.location_shares(owner_id);
CREATE INDEX IF NOT EXISTS idx_location_shares_recipient ON public.location_shares(recipient_id);
CREATE INDEX IF NOT EXISTS idx_location_shares_active
  ON public.location_shares(owner_id, recipient_id, expires_at)
  WHERE revoked_at IS NULL;

CREATE TRIGGER set_location_shares_updated_at
  BEFORE UPDATE ON public.location_shares
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ------------------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- Strict least-privilege model: no anonymous access, friendship verification
-- ------------------------------------------------------------------------------

-- Enable RLS across all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_shares ENABLE ROW LEVEL SECURITY;

-- 7.1. PROFILES POLICIES
-- Authenticated users can view profiles
CREATE POLICY "profiles_select_authenticated"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- Users can only insert their own profile
CREATE POLICY "profiles_insert_own"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "profiles_update_own"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 7.2. FRIENDSHIPS POLICIES
-- Users can see friendships where they are either requester or addressee
CREATE POLICY "friendships_select_involved"
  ON public.friendships
  FOR SELECT
  TO authenticated
  USING (auth.uid() = requester_id OR auth.uid() = addressee_id);

-- Users can send a friendship request as the requester
CREATE POLICY "friendships_insert_requester"
  ON public.friendships
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

-- Either party can update the friendship (e.g., accept, reject, block)
CREATE POLICY "friendships_update_involved"
  ON public.friendships
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = requester_id OR auth.uid() = addressee_id)
  WITH CHECK (auth.uid() = requester_id OR auth.uid() = addressee_id);

-- 7.3. FRIEND INVITES POLICIES
-- Inviter can see their own invites, or any authenticated user can view an active invite by hash
CREATE POLICY "friend_invites_select_authenticated"
  ON public.friend_invites
  FOR SELECT
  TO authenticated
  USING (
    inviter_id = auth.uid() OR
    (accepted_at IS NULL AND expires_at > timezone('utc'::text, now()))
  );

-- Only authenticated users can create invites where they are the inviter
CREATE POLICY "friend_invites_insert_own"
  ON public.friend_invites
  FOR INSERT
  TO authenticated
  WITH CHECK (inviter_id = auth.uid());

-- Updating an invite to mark it accepted
CREATE POLICY "friend_invites_update_accept"
  ON public.friend_invites
  FOR UPDATE
  TO authenticated
  USING (
    inviter_id = auth.uid() OR
    (accepted_at IS NULL AND expires_at > timezone('utc'::text, now()))
  )
  WITH CHECK (
    accepted_by = auth.uid() OR inviter_id = auth.uid()
  );

-- 7.4. LOCATION SHARES POLICIES
-- Helper function to verify active accepted friendship
CREATE OR REPLACE FUNCTION public.are_friends(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.friendships
    WHERE status = 'accepted'
      AND (
        (requester_id = user_a AND addressee_id = user_b) OR
        (requester_id = user_b AND addressee_id = user_a)
      )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SELECT: Accessible only if:
-- 1. Caller is owner or designated recipient
-- 2. Sharing session has not been revoked (revoked_at IS NULL)
-- 3. Sharing session has not expired (expires_at > now())
-- 4. An active, accepted friendship exists between owner and recipient
CREATE POLICY "location_shares_select_authorized"
  ON public.location_shares
  FOR SELECT
  TO authenticated
  USING (
    (auth.uid() = owner_id OR auth.uid() = recipient_id)
    AND revoked_at IS NULL
    AND expires_at > timezone('utc'::text, now())
    AND public.are_friends(owner_id, recipient_id)
  );

-- INSERT: Only the location owner can create a share session, and only with a verified friend
CREATE POLICY "location_shares_insert_owner"
  ON public.location_shares
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = owner_id
    AND public.are_friends(owner_id, recipient_id)
  );

-- UPDATE: Only the location owner can update their location or revoke the session
-- Crucial security rule: Recipient can NEVER update owner's coordinates or status
CREATE POLICY "location_shares_update_owner"
  ON public.location_shares
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- DELETE: Only the owner can remove a share record
CREATE POLICY "location_shares_delete_owner"
  ON public.location_shares
  FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);

-- ------------------------------------------------------------------------------
-- 8. SUPABASE REALTIME CONFIGURATION
-- Publish location updates to Supabase Realtime for subscriber notifications
-- ------------------------------------------------------------------------------
ALTER PUBLICATION supabase_realtime ADD TABLE public.location_shares;
