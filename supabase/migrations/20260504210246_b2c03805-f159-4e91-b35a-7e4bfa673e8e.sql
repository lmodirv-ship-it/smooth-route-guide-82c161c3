CREATE POLICY "Admins manage all ride requests"
ON public.ride_requests FOR ALL
TO authenticated
USING (
  public.has_role(auth.uid(), 'admin')
  OR public.has_role(auth.uid(), 'agent')
)
WITH CHECK (
  public.has_role(auth.uid(), 'admin')
  OR public.has_role(auth.uid(), 'agent')
);

CREATE POLICY "Admins manage all delivery orders"
ON public.delivery_orders FOR ALL
TO authenticated
USING (
  public.has_role(auth.uid(), 'admin')
  OR public.has_role(auth.uid(), 'agent')
)
WITH CHECK (
  public.has_role(auth.uid(), 'admin')
  OR public.has_role(auth.uid(), 'agent')
);