
CREATE TABLE IF NOT EXISTS public.smart_assistant_config (
  id smallint PRIMARY KEY DEFAULT 1,
  is_enabled boolean NOT NULL DEFAULT true,
  model text NOT NULL DEFAULT 'google/gemini-3-flash-preview',
  system_prompt text NOT NULL DEFAULT 'أنت مساعد ذكي محترف لمنصة HN Driver. كن دقيقاً وودوداً.',
  temperature numeric(3,2) NOT NULL DEFAULT 0.7,
  max_messages_per_session integer NOT NULL DEFAULT 30,
  daily_request_limit integer NOT NULL DEFAULT 200,
  allowed_roles text[] NOT NULL DEFAULT ARRAY['admin','agent','smart_admin_assistant','moderator','driver','delivery','store_owner','user']::text[],
  voice_enabled boolean NOT NULL DEFAULT true,
  file_uploads_enabled boolean NOT NULL DEFAULT true,
  maintenance_message text NOT NULL DEFAULT 'المساعد الذكي متوقف مؤقتاً للصيانة. عد لاحقاً.',
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  CONSTRAINT smart_assistant_config_singleton CHECK (id = 1)
);

GRANT SELECT ON public.smart_assistant_config TO authenticated, anon;
GRANT UPDATE ON public.smart_assistant_config TO authenticated;
GRANT ALL ON public.smart_assistant_config TO service_role;

ALTER TABLE public.smart_assistant_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anyone_can_read_assistant_config"
  ON public.smart_assistant_config FOR SELECT
  USING (true);

CREATE POLICY "only_admin_can_update_assistant_config"
  ON public.smart_assistant_config FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

INSERT INTO public.smart_assistant_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.smart_assistant_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  changed_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  previous_value jsonb,
  new_value jsonb,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT ON public.smart_assistant_audit_log TO authenticated;
GRANT ALL ON public.smart_assistant_audit_log TO service_role;

ALTER TABLE public.smart_assistant_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_can_read_assistant_audit"
  ON public.smart_assistant_audit_log FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE POLICY "admin_can_insert_assistant_audit"
  ON public.smart_assistant_audit_log FOR INSERT
  TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role) AND changed_by = auth.uid());

CREATE INDEX IF NOT EXISTS idx_assistant_audit_created_at ON public.smart_assistant_audit_log (created_at DESC);

CREATE OR REPLACE FUNCTION public.smart_assistant_config_touch()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_action text;
BEGIN
  NEW.updated_at := now();
  NEW.updated_by := auth.uid();

  IF NEW.is_enabled IS DISTINCT FROM OLD.is_enabled THEN
    v_action := CASE WHEN NEW.is_enabled THEN 'enable' ELSE 'disable' END;
    INSERT INTO public.smart_assistant_audit_log(action, changed_by, previous_value, new_value)
    VALUES (v_action, auth.uid(), to_jsonb(OLD), to_jsonb(NEW));
  ELSE
    INSERT INTO public.smart_assistant_audit_log(action, changed_by, previous_value, new_value)
    VALUES ('update', auth.uid(), to_jsonb(OLD), to_jsonb(NEW));
  END IF;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_smart_assistant_config_touch ON public.smart_assistant_config;
CREATE TRIGGER trg_smart_assistant_config_touch
  BEFORE UPDATE ON public.smart_assistant_config
  FOR EACH ROW EXECUTE FUNCTION public.smart_assistant_config_touch();
