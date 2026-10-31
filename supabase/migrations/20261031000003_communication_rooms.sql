-- ==============================================================================
-- TAUT — PostgreSQL Database Migration: Communication Rooms & Capacity Constraints
-- Stage 03: Communication Room Engine & Multi-User Governance
-- Author: Alfredo Jonathan Purba (Team Lead & Backend Architect)
-- Team: Mardua Holong (INCEPTION 2026 Hackathon)
-- ==============================================================================

-- 1. COMMUNICATION ROOMS TABLE
-- Real-time distance communication rooms for Deaf and Hearing peers
CREATE TABLE IF NOT EXISTS public.communication_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_auto_accept BOOLEAN NOT NULL DEFAULT false,
  max_participants INT NOT NULL DEFAULT 10,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ended')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  ended_at TIMESTAMPTZ,

  -- Capacity restriction: Maximum 10 people per room
  CONSTRAINT check_max_participants_cap CHECK (max_participants <= 10)
);

-- Constraint: 1 user can only create/host 1 active room at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_room_per_host
  ON public.communication_rooms (host_id)
  WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_rooms_code ON public.communication_rooms(room_code);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON public.communication_rooms(status);

-- ------------------------------------------------------------------------------
-- 2. ROOM PARTICIPANTS TABLE
-- Tracks participant membership and approval status
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.room_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES public.communication_rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'participant' CHECK (role IN ('host', 'participant')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('pending', 'active', 'left', 'rejected')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  left_at TIMESTAMPTZ,

  -- A user cannot have multiple active records in the same room
  CONSTRAINT uq_room_user_active UNIQUE (room_id, user_id, status)
);

-- Constraint: 1 user can only participate in 1 active/pending room at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_room_per_user
  ON public.room_participants (user_id)
  WHERE status IN ('active', 'pending');

CREATE INDEX IF NOT EXISTS idx_room_participants_room ON public.room_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_user ON public.room_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_status ON public.room_participants(status);

-- ------------------------------------------------------------------------------
-- 3. CAPACITY ENFORCEMENT TRIGGER (MAX 10 PARTICIPANTS)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_room_capacity()
RETURNS TRIGGER AS $$
DECLARE
  current_count INT;
  room_max INT;
BEGIN
  IF NEW.status = 'active' THEN
    SELECT max_participants INTO room_max
    FROM public.communication_rooms
    WHERE id = NEW.room_id;

    SELECT COUNT(*) INTO current_count
    FROM public.room_participants
    WHERE room_id = NEW.room_id AND status = 'active' AND id <> COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid);

    IF current_count >= COALESCE(room_max, 10) THEN
      RAISE EXCEPTION 'Kapasitas ruangan telah penuh (maksimal % peserta).', COALESCE(room_max, 10);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_room_capacity ON public.room_participants;
CREATE TRIGGER trg_enforce_room_capacity
  BEFORE INSERT OR UPDATE ON public.room_participants
  FOR EACH ROW
  EXECUTE FUNCTION public.check_room_capacity();

-- ------------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.communication_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_participants ENABLE ROW LEVEL SECURITY;

-- 4.1. COMMUNICATION ROOMS POLICIES
CREATE POLICY "rooms_select_active"
  ON public.communication_rooms
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "rooms_insert_host"
  ON public.communication_rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = host_id);

CREATE POLICY "rooms_update_host"
  ON public.communication_rooms
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = host_id)
  WITH CHECK (auth.uid() = host_id);

-- 4.2. ROOM PARTICIPANTS POLICIES
CREATE POLICY "participants_select_involved"
  ON public.room_participants
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.communication_rooms r
      WHERE r.id = room_participants.room_id AND r.host_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.room_participants p
      WHERE p.room_id = room_participants.room_id AND p.user_id = auth.uid() AND p.status = 'active'
    )
  );

CREATE POLICY "participants_insert_self"
  ON public.room_participants
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "participants_update_self_or_host"
  ON public.room_participants
  FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.communication_rooms r
      WHERE r.id = room_participants.room_id AND r.host_id = auth.uid()
    )
  );

-- ------------------------------------------------------------------------------
-- 5. STORED PROCEDURES / RPCs FOR ATOMIC ROOM OPERATIONS
-- ------------------------------------------------------------------------------

-- Create Room (Atomically checks 1-room constraint and sets host participant)
CREATE OR REPLACE FUNCTION public.rpc_create_communication_room(
  p_name TEXT,
  p_room_code TEXT,
  p_auto_accept BOOLEAN DEFAULT false
)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_room_id UUID;
  v_result JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Akses ditolak: Pengguna belum terautentikasi.';
  END IF;

  -- Verify user is not already in an active room
  IF EXISTS (
    SELECT 1 FROM public.room_participants
    WHERE user_id = v_user_id AND status IN ('active', 'pending')
  ) THEN
    RAISE EXCEPTION 'Pengguna masih berada dalam ruangan aktif lain. Selesaikan atau keluar terlebih dahulu.';
  END IF;

  -- Create new room
  INSERT INTO public.communication_rooms (
    room_code,
    name,
    host_id,
    is_auto_accept,
    max_participants,
    status
  ) VALUES (
    UPPER(TRIM(p_room_code)),
    TRIM(p_name),
    v_user_id,
    p_auto_accept,
    10,
    'active'
  ) RETURNING id INTO v_room_id;

  -- Add host as initial active participant
  INSERT INTO public.room_participants (
    room_id,
    user_id,
    role,
    status
  ) VALUES (
    v_room_id,
    v_user_id,
    'host',
    'active'
  );

  SELECT jsonb_build_object(
    'room_id', v_room_id,
    'room_code', p_room_code,
    'name', p_name,
    'max_participants', 10,
    'status', 'active'
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Join Room by Code (Atomically checks capacity <= 10 and 1-room constraint)
CREATE OR REPLACE FUNCTION public.rpc_join_communication_room(
  p_room_code TEXT
)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_room RECORD;
  v_active_count INT;
  v_new_status TEXT;
  v_participant_id UUID;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Akses ditolak: Pengguna belum terautentikasi.';
  END IF;

  -- Verify user is not already participating elsewhere
  IF EXISTS (
    SELECT 1 FROM public.room_participants
    WHERE user_id = v_user_id AND status IN ('active', 'pending')
  ) THEN
    RAISE EXCEPTION 'Pengguna sudah bergabung dalam ruangan lain. Satu pengguna hanya dapat bergabung ke satu ruangan.';
  END IF;

  -- Find active room
  SELECT * INTO v_room
  FROM public.communication_rooms
  WHERE room_code = UPPER(TRIM(p_room_code)) AND status = 'active';

  IF v_room IS NULL THEN
    RAISE EXCEPTION 'Ruang obrolan dengan kode % tidak ditemukan atau sudah berakhir.', p_room_code;
  END IF;

  -- Count current active participants
  SELECT COUNT(*) INTO v_active_count
  FROM public.room_participants
  WHERE room_id = v_room.id AND status = 'active';

  IF v_active_count >= v_room.max_participants THEN
    RAISE EXCEPTION 'Ruangan sudah penuh. Maksimal peserta adalah % orang.', v_room.max_participants;
  END IF;

  v_new_status := CASE WHEN v_room.is_auto_accept THEN 'active' ELSE 'pending' END;

  INSERT INTO public.room_participants (
    room_id,
    user_id,
    role,
    status
  ) VALUES (
    v_room.id,
    v_user_id,
    'participant',
    v_new_status
  ) RETURNING id INTO v_participant_id;

  RETURN jsonb_build_object(
    'participant_id', v_participant_id,
    'room_id', v_room.id,
    'room_name', v_room.name,
    'status', v_new_status,
    'is_auto_accepted', v_room.is_auto_accept
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 6. PROFILE AVATAR STORAGE & METADATA
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar."
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

