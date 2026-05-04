-- ride_requests: only ride drivers
DROP POLICY IF EXISTS "Drivers can view pending requests in area" ON public.ride_requests;
DROP POLICY IF EXISTS "Drivers can update pending requests" ON public.ride_requests;

CREATE POLICY "Ride drivers can view pending requests in area"
ON public.ride_requests
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.drivers
    WHERE user_id = auth.uid()
      AND driver_type = 'ride'
  )
);

CREATE POLICY "Ride drivers can update pending requests"
ON public.ride_requests
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.drivers
    WHERE user_id = auth.uid()
      AND driver_type = 'ride'
  )
);

-- delivery_orders: only delivery drivers (for driver-side accept/view of pending)
DROP POLICY IF EXISTS "Drivers can view pending delivery orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Drivers can update pending delivery orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Drivers can view delivery pending requests" ON public.delivery_orders;
DROP POLICY IF EXISTS "Drivers can update delivery pending requests" ON public.delivery_orders;

CREATE POLICY "Delivery drivers can view pending delivery orders"
ON public.delivery_orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.drivers
    WHERE user_id = auth.uid()
      AND driver_type = 'delivery'
  )
  OR driver_id IN (SELECT id FROM public.drivers WHERE user_id = auth.uid())
  OR user_id = auth.uid()
);

CREATE POLICY "Delivery drivers can update pending delivery orders"
ON public.delivery_orders
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.drivers
    WHERE user_id = auth.uid()
      AND driver_type = 'delivery'
  )
  OR driver_id IN (SELECT id FROM public.drivers WHERE user_id = auth.uid())
);