
-- Fix: Delivery drivers had blanket SELECT/UPDATE on delivery_orders via OR-EXISTS branch
DROP POLICY IF EXISTS "Delivery drivers can view pending delivery orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Delivery drivers can update pending delivery orders" ON public.delivery_orders;

-- Re-add narrowly scoped equivalents: only unassigned pending/ready orders are visible to delivery drivers.
-- Assigned orders are already covered by "Delivery drivers can view assigned orders".
CREATE POLICY "Delivery drivers can view unassigned pending orders"
ON public.delivery_orders
FOR SELECT
USING (
  driver_id IS NULL
  AND status IN ('pending', 'pending_call_center', 'ready_for_driver')
  AND has_role(auth.uid(), 'delivery'::app_role)
);

CREATE POLICY "Delivery drivers can accept unassigned pending orders"
ON public.delivery_orders
FOR UPDATE
USING (
  driver_id IS NULL
  AND status IN ('pending', 'pending_call_center', 'ready_for_driver')
  AND has_role(auth.uid(), 'delivery'::app_role)
);

-- Fix: Ride drivers had unrestricted SELECT/UPDATE on ride_requests
DROP POLICY IF EXISTS "Ride drivers can view pending requests in area" ON public.ride_requests;
DROP POLICY IF EXISTS "Ride drivers can update pending requests" ON public.ride_requests;

-- Re-add: only unassigned pending requests are visible to active ride drivers
CREATE POLICY "Ride drivers can view unassigned pending requests"
ON public.ride_requests
FOR SELECT
USING (
  driver_id IS NULL
  AND status = 'pending'
  AND EXISTS (
    SELECT 1 FROM public.drivers
    WHERE drivers.user_id = auth.uid()
      AND drivers.driver_type = 'ride'
      AND drivers.status = 'active'
  )
);

CREATE POLICY "Ride drivers can accept unassigned pending requests"
ON public.ride_requests
FOR UPDATE
USING (
  driver_id IS NULL
  AND status = 'pending'
  AND EXISTS (
    SELECT 1 FROM public.drivers
    WHERE drivers.user_id = auth.uid()
      AND drivers.driver_type = 'ride'
      AND drivers.status = 'active'
  )
);
