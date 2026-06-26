
-- ============================================================
-- FIX: درايفر "both" و"delivery" يجب أن يرى طلبات التوصيل
-- ودرايفر "both" يجب أن يرى طلبات الرحلات
-- ============================================================

-- 1) ride_requests: السماح لـ ride أو both
DROP POLICY IF EXISTS "Ride drivers can view unassigned pending requests" ON public.ride_requests;
CREATE POLICY "Ride drivers can view unassigned pending requests"
  ON public.ride_requests
  FOR SELECT
  TO authenticated
  USING (
    driver_id IS NULL
    AND status = 'pending'
    AND EXISTS (
      SELECT 1 FROM public.drivers d
      WHERE d.user_id = auth.uid()
        AND d.driver_type IN ('ride','both')
        AND d.status = 'active'
    )
  );

DROP POLICY IF EXISTS "Ride drivers can accept unassigned pending requests" ON public.ride_requests;
CREATE POLICY "Ride drivers can accept unassigned pending requests"
  ON public.ride_requests
  FOR UPDATE
  TO authenticated
  USING (
    driver_id IS NULL
    AND status = 'pending'
    AND EXISTS (
      SELECT 1 FROM public.drivers d
      WHERE d.user_id = auth.uid()
        AND d.driver_type IN ('ride','both')
        AND d.status = 'active'
    )
  )
  WITH CHECK (
    status IN ('accepted','pending')
    AND (
      driver_id IS NULL
      OR driver_id IN (SELECT d.id FROM public.drivers d WHERE d.user_id = auth.uid())
    )
  );

-- 2) ride_requests: تأكد أن السائق يستطيع رؤية طلباته المعينة (assigned/in_progress/arriving/completed/cancelled)
DROP POLICY IF EXISTS "Drivers can view own assigned ride requests" ON public.ride_requests;
CREATE POLICY "Drivers can view own assigned ride requests"
  ON public.ride_requests
  FOR SELECT
  TO authenticated
  USING (
    driver_id IN (SELECT d.id FROM public.drivers d WHERE d.user_id = auth.uid())
  );

-- 3) delivery_orders: السماح لـ delivery أو both بقبول الطلبات غير المعيّنة
DROP POLICY IF EXISTS "Delivery drivers can accept unassigned pending orders" ON public.delivery_orders;
CREATE POLICY "Delivery drivers can accept unassigned pending orders"
  ON public.delivery_orders
  FOR UPDATE
  TO authenticated
  USING (
    driver_id IS NULL
    AND status = ANY (ARRAY['pending','pending_call_center','ready_for_driver'])
    AND (
      public.has_role(auth.uid(), 'delivery'::public.app_role)
      OR public.has_role(auth.uid(), 'driver'::public.app_role)
    )
    AND EXISTS (
      SELECT 1 FROM public.drivers d
      WHERE d.user_id = auth.uid()
        AND d.driver_type IN ('delivery','both')
        AND d.status = 'active'
    )
  )
  WITH CHECK (
    status = 'driver_assigned'
    AND driver_id IN (SELECT d.id FROM public.drivers d WHERE d.user_id = auth.uid())
  );

-- 4) Updated function: توسيع لتشمل drivers بنوع delivery/both ولا تتطلب فقط دور delivery
CREATE OR REPLACE FUNCTION public.available_delivery_orders()
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
      OR public.has_role(auth.uid(), 'admin'::public.app_role)
      OR public.has_role(auth.uid(), 'agent'::public.app_role)
    )
    AND (
      public.has_role(auth.uid(), 'admin'::public.app_role)
      OR public.has_role(auth.uid(), 'agent'::public.app_role)
      OR EXISTS (
        SELECT 1 FROM public.drivers d
        WHERE d.user_id = auth.uid()
          AND d.driver_type IN ('delivery','both')
          AND d.status = 'active'
      )
    );
$$;

REVOKE EXECUTE ON FUNCTION public.available_delivery_orders() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.available_delivery_orders() TO authenticated;
