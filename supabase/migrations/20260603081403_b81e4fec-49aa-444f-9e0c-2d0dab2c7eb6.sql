
-- ============================================================
-- SECURITY FIXES
-- ============================================================

-- 1) Realtime: remove the broad `public-%` topic clause so any authenticated
--    user can no longer subscribe/publish to arbitrary public-* channels.
DROP POLICY IF EXISTS "Users can insert to own channels" ON realtime.messages;
DROP POLICY IF EXISTS "Users can only access own channels" ON realtime.messages;

CREATE POLICY "Users can insert to own channels"
  ON realtime.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (realtime.topic() LIKE ('%' || (auth.uid())::text || '%'))
    OR (
      realtime.topic() LIKE 'api-sync-%'
      AND (public.has_role(auth.uid(), 'admin'::public.app_role)
           OR public.has_role(auth.uid(), 'agent'::public.app_role))
    )
  );

CREATE POLICY "Users can only access own channels"
  ON realtime.messages
  FOR SELECT
  TO authenticated
  USING (
    (realtime.topic() LIKE ('%' || (auth.uid())::text || '%'))
    OR (
      realtime.topic() LIKE 'api-sync-%'
      AND (public.has_role(auth.uid(), 'admin'::public.app_role)
           OR public.has_role(auth.uid(), 'agent'::public.app_role))
    )
  );

-- 2) delivery_orders: stop broadcasting customer PII to every authenticated
--    delivery driver. Drop the broad "pending"/"ready"/"unassigned" SELECT
--    policies and expose a sanitized RPC that omits customer_phone/email.
--    Assigned drivers keep full row access via the existing
--    "Drivers can view assigned delivery orders" / "Delivery drivers can view
--    assigned orders" policies.
DROP POLICY IF EXISTS "Delivery drivers can view pending orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Delivery drivers can view ready orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Delivery drivers can view unassigned pending orders" ON public.delivery_orders;
DROP POLICY IF EXISTS "Drivers can view ready_for_driver orders" ON public.delivery_orders;

CREATE OR REPLACE FUNCTION public.available_delivery_orders()
RETURNS TABLE (
  id uuid,
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
    o.id, o.category, o.store_name, o.store_id,
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

GRANT EXECUTE ON FUNCTION public.available_delivery_orders() TO authenticated;

-- 3) stores.email: block anonymous browsers from harvesting operator emails.
REVOKE SELECT (email) ON public.stores FROM anon;

-- 4) hn_stock_merchants: lock down bank_account_number and api_key columns so
--    they cannot be read via the broad admin SELECT path. Expose a controlled
--    SECURITY DEFINER getter for the merchant owner and admins only.
REVOKE SELECT (bank_account_number, api_key) ON public.hn_stock_merchants FROM anon, authenticated;
GRANT SELECT (bank_account_number, api_key) ON public.hn_stock_merchants TO service_role;

CREATE OR REPLACE FUNCTION public.get_merchant_credentials(p_merchant_id uuid)
RETURNS TABLE (bank_account_number text, api_key text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner uuid;
BEGIN
  SELECT user_id INTO v_owner FROM public.hn_stock_merchants WHERE id = p_merchant_id;
  IF v_owner IS NULL THEN
    RAISE EXCEPTION 'merchant_not_found';
  END IF;
  IF NOT (public.has_role(auth.uid(), 'admin'::public.app_role) OR v_owner = auth.uid()) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  RETURN QUERY
    SELECT m.bank_account_number, m.api_key
    FROM public.hn_stock_merchants m
    WHERE m.id = p_merchant_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_merchant_credentials(uuid) TO authenticated;

-- 5) face_auth_*: biometric data must not be readable through the table API.
--    Block descriptor / photo_url / photo_data from anon and authenticated;
--    only service_role (edge functions) can read them server-side.
REVOKE SELECT (descriptor, photo_url) ON public.face_auth_profiles FROM anon, authenticated;
GRANT SELECT (descriptor, photo_url) ON public.face_auth_profiles TO service_role;

REVOKE SELECT (photo_data) ON public.face_auth_attempts FROM anon, authenticated;
GRANT SELECT (photo_data) ON public.face_auth_attempts TO service_role;
