-- Performance indexes for hottest queries identified by pg_stat_statements
CREATE INDEX IF NOT EXISTS idx_delivery_orders_status_driver
  ON public.delivery_orders (status, driver_id);
CREATE INDEX IF NOT EXISTS idx_delivery_orders_created_at
  ON public.delivery_orders (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_delivery_orders_user_id
  ON public.delivery_orders (user_id);

CREATE INDEX IF NOT EXISTS idx_trips_created_at
  ON public.trips (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_trips_status
  ON public.trips (status);
CREATE INDEX IF NOT EXISTS idx_trips_driver_id
  ON public.trips (driver_id);
CREATE INDEX IF NOT EXISTS idx_trips_user_id
  ON public.trips (user_id);

CREATE INDEX IF NOT EXISTS idx_ride_requests_status_driver
  ON public.ride_requests (status, driver_id);
CREATE INDEX IF NOT EXISTS idx_ride_requests_created_at
  ON public.ride_requests (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ride_requests_user_id
  ON public.ride_requests (user_id);

CREATE INDEX IF NOT EXISTS idx_earnings_date_driver
  ON public.earnings (date DESC, driver_id);

CREATE INDEX IF NOT EXISTS idx_drivers_user_id
  ON public.drivers (user_id);
CREATE INDEX IF NOT EXISTS idx_drivers_status_type
  ON public.drivers (status, driver_type);

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id
  ON public.user_roles (user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_created_type
  ON public.analytics_events (created_at DESC, event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_session
  ON public.analytics_events (session_id);