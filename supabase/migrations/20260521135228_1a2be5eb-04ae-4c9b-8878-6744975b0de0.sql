
ALTER TABLE public.drivers
ADD COLUMN IF NOT EXISTS online_since timestamptz;

-- Initialize for currently-active drivers
UPDATE public.drivers
SET online_since = COALESCE(location_updated_at, now())
WHERE status = 'active' AND online_since IS NULL;

-- Trigger to set/clear online_since when status changes
CREATE OR REPLACE FUNCTION public.sync_driver_online_since()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.status = 'active' AND (OLD.status IS DISTINCT FROM 'active' OR NEW.online_since IS NULL) THEN
    NEW.online_since := now();
  ELSIF NEW.status <> 'active' AND OLD.status = 'active' THEN
    NEW.online_since := NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_driver_online_since ON public.drivers;
CREATE TRIGGER trg_sync_driver_online_since
BEFORE UPDATE OF status ON public.drivers
FOR EACH ROW
EXECUTE FUNCTION public.sync_driver_online_since();

-- Expose the new column on the public view used by the map
CREATE OR REPLACE VIEW public.active_drivers_public AS
SELECT id, car_id, status, rating, current_lat, current_lng, online_since
FROM public.drivers
WHERE status = 'active'
  AND current_lat IS NOT NULL
  AND current_lng IS NOT NULL;
