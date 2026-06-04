
-- 1. Fix analytics_events insert policy
DROP POLICY IF EXISTS anyone_insert_events ON public.analytics_events;
CREATE POLICY anyone_insert_events ON public.analytics_events
  FOR INSERT TO public
  WITH CHECK (user_id IS NULL OR user_id = auth.uid());

-- 2. Drivers self-update guard via trigger
CREATE OR REPLACE FUNCTION public.guard_driver_self_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.has_role(auth.uid(), 'admin'::public.app_role)
     OR public.has_role(auth.uid(), 'agent'::public.app_role) THEN
    RETURN NEW;
  END IF;

  IF OLD.user_id IS DISTINCT FROM auth.uid() THEN
    RETURN NEW;
  END IF;

  IF NEW.status        IS DISTINCT FROM OLD.status
  OR NEW.driver_type   IS DISTINCT FROM OLD.driver_type
  OR NEW.rating        IS DISTINCT FROM OLD.rating
  OR NEW.driver_code   IS DISTINCT FROM OLD.driver_code
  OR NEW.user_id       IS DISTINCT FROM OLD.user_id
  OR NEW.license_no    IS DISTINCT FROM OLD.license_no
  OR NEW.car_id        IS DISTINCT FROM OLD.car_id THEN
    RAISE EXCEPTION 'drivers_self_update_forbidden_columns'
      USING HINT = 'Drivers cannot modify status, driver_type, rating, code, vehicle, or license themselves';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_guard_driver_self_update ON public.drivers;
CREATE TRIGGER trg_guard_driver_self_update
BEFORE UPDATE ON public.drivers
FOR EACH ROW EXECUTE FUNCTION public.guard_driver_self_update();

-- 3. Delivery orders driver-update guard via trigger
CREATE OR REPLACE FUNCTION public.guard_delivery_order_driver_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_assigned_driver boolean;
BEGIN
  IF public.has_role(auth.uid(), 'admin'::public.app_role)
     OR public.has_role(auth.uid(), 'agent'::public.app_role)
     OR public.has_role(auth.uid(), 'smart_admin_assistant'::public.app_role) THEN
    RETURN NEW;
  END IF;

  -- Customer who owns the order can still edit through their own RLS
  IF OLD.user_id = auth.uid() THEN
    RETURN NEW;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.drivers d
    WHERE d.id = OLD.driver_id AND d.user_id = auth.uid()
  ) INTO v_is_assigned_driver;

  IF NOT v_is_assigned_driver THEN
    RETURN NEW;
  END IF;

  IF NEW.customer_name      IS DISTINCT FROM OLD.customer_name
  OR NEW.customer_phone     IS DISTINCT FROM OLD.customer_phone
  OR NEW.customer_email     IS DISTINCT FROM OLD.customer_email
  OR NEW.final_price        IS DISTINCT FROM OLD.final_price
  OR NEW.estimated_price    IS DISTINCT FROM OLD.estimated_price
  OR NEW.total_price        IS DISTINCT FROM OLD.total_price
  OR NEW.delivery_fee       IS DISTINCT FROM OLD.delivery_fee
  OR NEW.payment_method     IS DISTINCT FROM OLD.payment_method
  OR NEW.driver_net_earning IS DISTINCT FROM OLD.driver_net_earning
  OR NEW.user_id            IS DISTINCT FROM OLD.user_id
  OR NEW.store_id           IS DISTINCT FROM OLD.store_id
  OR NEW.items              IS DISTINCT FROM OLD.items THEN
    RAISE EXCEPTION 'delivery_order_driver_update_forbidden_columns'
      USING HINT = 'Drivers can only update status/timestamps/proof, not customer or pricing fields';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_guard_delivery_order_driver_update ON public.delivery_orders;
CREATE TRIGGER trg_guard_delivery_order_driver_update
BEFORE UPDATE ON public.delivery_orders
FOR EACH ROW EXECUTE FUNCTION public.guard_delivery_order_driver_update();

-- 4. Hide stores.commission_rate from non-admin/agent reads via column privileges
REVOKE SELECT (commission_rate) ON public.stores FROM anon, authenticated;

-- Provide a helper for admin/agent UIs to read commission rates
CREATE OR REPLACE FUNCTION public.get_store_commission(p_store_id uuid)
RETURNS numeric
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rate numeric;
BEGIN
  IF NOT (public.has_role(auth.uid(), 'admin'::public.app_role)
       OR public.has_role(auth.uid(), 'agent'::public.app_role)) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  SELECT commission_rate INTO v_rate FROM public.stores WHERE id = p_store_id;
  RETURN v_rate;
END;
$$;
