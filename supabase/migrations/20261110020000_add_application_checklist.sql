-- Phase 3F: Persist per-circular application checklist booleans on
-- public.circulars so checklist state syncs across sessions and devices.

ALTER TABLE public.circulars
  ADD COLUMN checklist_photo boolean NOT NULL DEFAULT false,
  ADD COLUMN checklist_certificates boolean NOT NULL DEFAULT false,
  ADD COLUMN checklist_fee_paid boolean NOT NULL DEFAULT false,
  ADD COLUMN checklist_submitted boolean NOT NULL DEFAULT false,
  ADD COLUMN checklist_admit_card_downloaded boolean NOT NULL DEFAULT false;
