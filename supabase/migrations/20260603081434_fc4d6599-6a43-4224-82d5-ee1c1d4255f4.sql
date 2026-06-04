
DROP FUNCTION IF EXISTS public.available_delivery_orders();

CREATE FUNCTION public.available_delivery_orders()
RETURNS TABLE (
  id uuid,
  user_id uuid,
  category text,
  store_name text,
  store_id uuid,
  pickup_address text,
  pickup_lat numeric,
  pickup_lng numeric,
  delivery_address text,
  delivery_lat numeric,
  delivery_lng numeric,
  status text,
  estimated_price numeric,
  delivery_fee numeric,
  total_price numeric,
  distance numeric,
  estimated_time integer,
  notes text,
  city text,
  country text,
  order_code text,
  payment_method text,
  delivery_type text,
  zone_id uuid,
  items jsonb,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    o.id, o.user_id, o.category, o.store_name, o.store_id,
    o.pickup_address, o.pickup_lat, o.pickup_lng,
    o.delivery_address, o.delivery_lat, o.delivery_lng,
    o.status, o.estimated_price, o.delivery_fee, o.total_price,
    o.distance, o.estimated_time, o.notes, o.city, o.country,
    o.order_code, o.payment_method, o.delivery_type, o.zone_id,
    o.items, o.created_at
  FROM public.delivery_orders o
  WHERE o.driver_id IS NULL
    AND o.status = ANY (ARRAY['pending','pending_call_center','ready_for_driver'])
    AND (
      public.has_role(auth.uid(), 'delivery'::public.app_role)
      OR public.has_role(auth.uid(), 'driver'::public.app_role)
    );
$$;

REVOKE EXECUTE ON FUNCTION public.available_delivery_orders() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.available_delivery_orders() TO authenticated;
