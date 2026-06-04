
CREATE TABLE IF NOT EXISTS public.driver_work_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  duration_minutes integer,
  work_date date NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')::date,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dws_driver_date ON public.driver_work_sessions(driver_id, work_date);
CREATE INDEX IF NOT EXISTS idx_dws_open ON public.driver_work_sessions(driver_id) WHERE ended_at IS NULL;

ALTER TABLE public.driver_work_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins read driver sessions" ON public.driver_work_sessions;
CREATE POLICY "Admins read driver sessions"
  ON public.driver_work_sessions FOR SELECT
  TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin')
    OR EXISTS (SELECT 1 FROM public.drivers d WHERE d.id = driver_work_sessions.driver_id AND d.user_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.record_driver_work_session()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_now timestamptz := now();
  v_open RECORD;
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'active' THEN
    INSERT INTO public.driver_work_sessions(driver_id, started_at, work_date)
    VALUES (NEW.id, v_now, (v_now AT TIME ZONE 'UTC')::date);
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    IF NEW.status = 'active' THEN
      IF NOT EXISTS (SELECT 1 FROM public.driver_work_sessions WHERE driver_id = NEW.id AND ended_at IS NULL) THEN
        INSERT INTO public.driver_work_sessions(driver_id, started_at, work_date)
        VALUES (NEW.id, v_now, (v_now AT TIME ZONE 'UTC')::date);
      END IF;
    ELSIF OLD.status = 'active' THEN
      FOR v_open IN
        SELECT id, started_at FROM public.driver_work_sessions
        WHERE driver_id = NEW.id AND ended_at IS NULL
      LOOP
        UPDATE public.driver_work_sessions
          SET ended_at = v_now,
              duration_minutes = GREATEST(0, EXTRACT(EPOCH FROM (v_now - v_open.started_at))::int / 60)
          WHERE id = v_open.id;
      END LOOP;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_record_driver_work_session_ins ON public.drivers;
CREATE TRIGGER trg_record_driver_work_session_ins
AFTER INSERT ON public.drivers
FOR EACH ROW EXECUTE FUNCTION public.record_driver_work_session();

DROP TRIGGER IF EXISTS trg_record_driver_work_session_upd ON public.drivers;
CREATE TRIGGER trg_record_driver_work_session_upd
AFTER UPDATE OF status ON public.drivers
FOR EACH ROW EXECUTE FUNCTION public.record_driver_work_session();

CREATE OR REPLACE FUNCTION public.driver_daily_hours(p_driver_id uuid, p_days integer DEFAULT 7)
RETURNS TABLE(day date, minutes integer)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH closed AS (
    SELECT work_date AS day, COALESCE(SUM(duration_minutes), 0)::int AS minutes
    FROM public.driver_work_sessions
    WHERE driver_id = p_driver_id
      AND ended_at IS NOT NULL
      AND work_date >= (now() AT TIME ZONE 'UTC')::date - (p_days - 1)
    GROUP BY work_date
  ),
  open_now AS (
    SELECT (now() AT TIME ZONE 'UTC')::date AS day,
           GREATEST(0, EXTRACT(EPOCH FROM (now() - MIN(started_at)))::int / 60) AS minutes
    FROM public.driver_work_sessions
    WHERE driver_id = p_driver_id AND ended_at IS NULL
    HAVING MIN(started_at) IS NOT NULL
  )
  SELECT day, SUM(minutes)::int AS minutes
  FROM (SELECT * FROM closed UNION ALL SELECT * FROM open_now) x
  GROUP BY day
  ORDER BY day DESC;
$$;

INSERT INTO public.driver_work_sessions(driver_id, started_at, work_date)
SELECT d.id, COALESCE(d.online_since, now()), (COALESCE(d.online_since, now()) AT TIME ZONE 'UTC')::date
FROM public.drivers d
WHERE d.status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM public.driver_work_sessions s
    WHERE s.driver_id = d.id AND s.ended_at IS NULL
  );
