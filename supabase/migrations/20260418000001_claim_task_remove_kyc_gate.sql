-- ============================================================================
-- Fix claim_delivery_task():
--   1. Remove redundant courier_kyc gate (profile.status is the source of
--      truth; is_approved_courier() already checks it).
--   2. Set app.claim_trigger_active = 'true' before the UPDATE so the
--      enforce_merchant_courier_immutable trigger allows the courier_id
--      assignment. Without this flag the remote trigger raises:
--        "courier_id can only be changed via claim_delivery_task()..."
-- ============================================================================
CREATE OR REPLACE FUNCTION public.claim_delivery_task(p_task_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_courier_id  UUID    := auth.uid();
  v_has_active  BOOLEAN;
  v_task        RECORD;
BEGIN
  -- Gate 1: only approved couriers (checks profiles.status = 'approved')
  IF NOT public.is_approved_courier() THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Таны бүртгэл баталгаажаагүй байна.',
      'task_id', p_task_id,
      'courier_id', v_courier_id
    );
  END IF;

  -- Gate 2: one active delivery at a time
  SELECT EXISTS (
    SELECT 1 FROM public.delivery_tasks
    WHERE  courier_id = v_courier_id
      AND  status::text IN ('assigned', 'picked_up', 'delivered')
  ) INTO v_has_active;

  IF v_has_active THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Танд идэвхтэй хүргэлт байна. Эхлэн дуусгасны дараа шинэ хүргэлт авна уу.',
      'task_id', p_task_id,
      'courier_id', v_courier_id
    );
  END IF;

  -- Atomically lock the row; SKIP LOCKED drops it if another session grabbed it
  SELECT * INTO v_task
  FROM   public.delivery_tasks
  WHERE  id     = p_task_id
    AND  status::text = 'published'
  FOR UPDATE SKIP LOCKED;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Энэ хүргэлт авах боломжгүй болсон байна.',
      'task_id', p_task_id,
      'courier_id', v_courier_id
    );
  END IF;

  -- Signal the immutability trigger(s) that this change is authorised
  PERFORM set_config('app.claim_trigger_active', 'true', true);
  PERFORM set_config('app.claim_in_progress',   'true', true);
  PERFORM set_config('app.via_claim_fn',        'on',   true);

  UPDATE public.delivery_tasks
  SET    status      = 'assigned',
         courier_id  = v_courier_id,
         assigned_at = NOW()
  WHERE  id = p_task_id;

  RETURN jsonb_build_object(
    'success',    true,
    'task_id',    p_task_id,
    'courier_id', v_courier_id,
    'message',    'Хүргэлт амжилттай хүлээн авлаа.'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.claim_delivery_task(UUID) TO authenticated;
