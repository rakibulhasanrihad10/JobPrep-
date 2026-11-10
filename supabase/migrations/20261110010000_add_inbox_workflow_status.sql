-- Phase 3E: Allow 'inbox' workflow_status for quick-captured circulars.

ALTER TABLE public.circulars
  DROP CONSTRAINT circulars_workflow_status_check;

ALTER TABLE public.circulars
  ADD CONSTRAINT circulars_workflow_status_check CHECK (
    workflow_status IN (
      'inbox',
      'saved',
      'preparing',
      'applied',
      'exam_upcoming',
      'result_awaited',
      'archived'
    )
  );
