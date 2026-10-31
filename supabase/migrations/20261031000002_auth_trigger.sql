-- ==============================================================================
-- TAUT — PostgreSQL Database Migration Draft: Auth Trigger
-- Stage 02: Backend Integration
-- Author: Alfredo Jonathan Purba (Team Lead & Backend Architect)
-- Description: Automatically provisions a row in public.profiles whenever a
-- new user registers via Supabase Auth (auth.users).
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'Pengguna TAUT')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger execution after insert on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
