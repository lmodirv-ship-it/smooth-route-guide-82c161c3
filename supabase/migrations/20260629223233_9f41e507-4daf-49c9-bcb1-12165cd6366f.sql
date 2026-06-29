
DROP POLICY IF EXISTS "Anyone can view active ads" ON public.ads;
CREATE POLICY "Anyone can view active ads"
ON public.ads FOR SELECT TO public
USING (
  is_active = true
  AND (start_date IS NULL OR start_date <= now())
  AND (end_date IS NULL OR end_date >= now())
);

DROP POLICY IF EXISTS "anyone_can_read_assistant_config" ON public.smart_assistant_config;
CREATE POLICY "admins_can_read_assistant_config"
ON public.smart_assistant_config FOR SELECT TO authenticated
USING (public.has_role(auth.uid(), 'admin'::public.app_role));
REVOKE SELECT ON public.smart_assistant_config FROM anon;

REVOKE SELECT ON public.stores FROM anon;
GRANT SELECT (
  id, name, description, category, zone_id, address, lat, lng,
  rating, delivery_time_min, delivery_time_max, delivery_fee, min_order,
  is_open, image_url, created_at, google_place_id, area, owner_id,
  city, country, store_code, is_confirmed
) ON public.stores TO anon;

REVOKE SELECT ON public.hn_stock_merchants FROM authenticated;
GRANT SELECT (
  id, user_id, name, email, phone, company_name, bank_name, status,
  preferred_warehouse, created_at, updated_at
) ON public.hn_stock_merchants TO authenticated;
