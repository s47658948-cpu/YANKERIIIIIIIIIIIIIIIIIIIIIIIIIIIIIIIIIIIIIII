ALTER TABLE public.penalties
ADD COLUMN IF NOT EXISTS payment_notice TEXT NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'unpaid',
ADD COLUMN IF NOT EXISTS payment_submitted_at BIGINT,
ADD COLUMN IF NOT EXISTS paid BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS paid_at BIGINT;

UPDATE public.penalties
SET payment_status = CASE WHEN paid THEN 'paid' ELSE 'unpaid' END
WHERE payment_status IS NULL OR payment_status = '';

CREATE INDEX IF NOT EXISTS penalties_payment_status_idx ON public.penalties(payment_status);
