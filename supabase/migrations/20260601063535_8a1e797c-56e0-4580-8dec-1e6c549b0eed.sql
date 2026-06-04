
-- 1) Enable RLS on invite_friend and lock it down
ALTER TABLE public.invite_friend ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.invite_friend FROM anon;
GRANT SELECT, INSERT ON public.invite_friend TO authenticated;
GRANT ALL ON public.invite_friend TO service_role;

DROP POLICY IF EXISTS "Admins can read invite_friend" ON public.invite_friend;
CREATE POLICY "Admins can read invite_friend"
  ON public.invite_friend FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Authenticated users can insert invitations" ON public.invite_friend;
CREATE POLICY "Authenticated users can insert invitations"
  ON public.invite_friend FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Admins can update invite_friend" ON public.invite_friend;
CREATE POLICY "Admins can update invite_friend"
  ON public.invite_friend FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can delete invite_friend" ON public.invite_friend;
CREATE POLICY "Admins can delete invite_friend"
  ON public.invite_friend FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- 2) Replace overly-permissive realtime.messages INSERT policy with topic-scoped one
DROP POLICY IF EXISTS "Users can insert to own channels" ON realtime.messages;
CREATE POLICY "Users can insert to own channels"
  ON realtime.messages FOR INSERT TO authenticated
  WITH CHECK (
    (realtime.topic() LIKE ('%' || auth.uid()::text || '%'))
    OR (realtime.topic() LIKE 'api-sync-%' AND (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'agent')))
    OR (realtime.topic() LIKE 'public-%')
  );

-- 3) app_settings: replace denylist with explicit allowlist of non-sensitive keys
DROP POLICY IF EXISTS "Authenticated can read non-sensitive settings" ON public.app_settings;
CREATE POLICY "Authenticated can read non-sensitive settings"
  ON public.app_settings FOR SELECT TO authenticated
  USING (
    key IN (
      'theme', 'active_theme', 'themes',
      'pricing', 'pricing_settings', 'delivery_pricing',
      'free_period', 'free_period_settings',
      'platform_parameters', 'app_parameters',
      'announcements', 'banners', 'ads_config',
      'feature_flags', 'features',
      'support_contact', 'contact_info',
      'tracking_ids', 'analytics_ids',
      'ota_manifest', 'app_version',
      'maintenance_mode', 'maintenance',
      'dispatch_settings', 'driver_settings',
      'i18n_overrides', 'translations_overrides'
    )
  );

-- 4) Convert SECURITY DEFINER view to security_invoker so RLS of caller applies
ALTER VIEW public.active_drivers_public SET (security_invoker = true);
