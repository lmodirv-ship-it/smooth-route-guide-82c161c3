-- Revoke commission_rate column SELECT from PUBLIC and from anon/authenticated.
-- Then re-grant SELECT on every OTHER column so the public storefront still works.
REVOKE SELECT (commission_rate) ON public.stores FROM PUBLIC;
REVOKE SELECT (commission_rate) ON public.stores FROM anon;
REVOKE SELECT (commission_rate) ON public.stores FROM authenticated;

DO $$
DECLARE
  v_cols text;
BEGIN
  SELECT string_agg(quote_ident(column_name), ', ')
  INTO v_cols
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'stores'
    AND column_name <> 'commission_rate';

  EXECUTE format('GRANT SELECT (%s) ON public.stores TO anon', v_cols);
  EXECUTE format('GRANT SELECT (%s) ON public.stores TO authenticated', v_cols);
END $$;

-- service_role keeps full access
GRANT SELECT ON public.stores TO service_role;