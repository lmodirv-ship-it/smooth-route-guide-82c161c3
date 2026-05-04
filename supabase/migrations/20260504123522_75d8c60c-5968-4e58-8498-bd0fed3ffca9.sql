
-- 1) Remove duplicate roles for owner (keep admin only)
DELETE FROM public.user_roles 
WHERE user_id = '22b66263-874b-498a-81f4-91be081765c2'::uuid 
  AND role <> 'admin';

-- 2) Ensure unique (user_id, role) to prevent any future duplicates
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'user_roles_user_id_role_key' 
       OR conname = 'user_roles_user_role_unique'
  ) THEN
    ALTER TABLE public.user_roles 
      ADD CONSTRAINT user_roles_user_role_unique UNIQUE (user_id, role);
  END IF;
END $$;

-- 3) Strengthen protect_admin_roles: also block INSERT of non-admin roles for the OWNER
CREATE OR REPLACE FUNCTION public.protect_admin_roles()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_owner_id uuid := '22b66263-874b-498a-81f4-91be081765c2'::uuid;
  v_protected_ids uuid[] := ARRAY[
    '338ea1c1-2ded-4622-a401-4d25c5930fa4'::uuid,
    '22b66263-874b-498a-81f4-91be081765c2'::uuid,
    '85dc53b8-2a20-425e-91eb-c3ab8f9fed00'::uuid
  ];
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.role = 'admin' AND OLD.user_id = ANY(v_protected_ids) THEN
      RAISE EXCEPTION 'Cannot remove admin role from a protected administrator';
    END IF;
    RETURN OLD;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF OLD.role = 'admin' AND NEW.role <> 'admin' AND OLD.user_id = ANY(v_protected_ids) THEN
      RAISE EXCEPTION 'Cannot change admin role for a protected administrator';
    END IF;
  END IF;

  -- Block adding any non-admin role to the OWNER (no role duplication for owner)
  IF TG_OP = 'INSERT' THEN
    IF NEW.user_id = v_owner_id AND NEW.role <> 'admin' THEN
      RAISE EXCEPTION 'Owner account can only hold the admin role';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

-- 4) Make sure trigger covers INSERT/UPDATE/DELETE
DROP TRIGGER IF EXISTS trg_protect_admin_roles ON public.user_roles;
CREATE TRIGGER trg_protect_admin_roles
  BEFORE INSERT OR UPDATE OR DELETE ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.protect_admin_roles();

-- 5) Protect the OWNER profile: block deletion and email change
CREATE OR REPLACE FUNCTION public.protect_owner_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_owner_id uuid := '22b66263-874b-498a-81f4-91be081765c2'::uuid;
  v_owner_email text := 'lmodirv@gmail.com';
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.id = v_owner_id THEN
      RAISE EXCEPTION 'Cannot delete the owner account';
    END IF;
    RETURN OLD;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF OLD.id = v_owner_id AND NEW.email IS DISTINCT FROM v_owner_email THEN
      RAISE EXCEPTION 'Cannot change owner email address';
    END IF;
    -- Prevent suspending the owner
    IF OLD.id = v_owner_id AND COALESCE(NEW.is_suspended, false) = true THEN
      RAISE EXCEPTION 'Cannot suspend the owner account';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_protect_owner_profile ON public.profiles;
CREATE TRIGGER trg_protect_owner_profile
  BEFORE UPDATE OR DELETE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_owner_profile();
