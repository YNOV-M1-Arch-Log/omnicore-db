-- Order Taking: capture where to deliver and customer notes
-- Order Processing: track shipping details, cancellation, and lifecycle timestamps

ALTER TABLE "orders"
  ADD COLUMN "shipping_address"    JSONB,
  ADD COLUMN "notes"               TEXT,
  ADD COLUMN "tracking_number"     VARCHAR(100),
  ADD COLUMN "shipping_provider"   VARCHAR(100),
  ADD COLUMN "estimated_delivery"  TIMESTAMP(3),
  ADD COLUMN "cancellation_reason" TEXT,
  ADD COLUMN "confirmed_at"        TIMESTAMP(3),
  ADD COLUMN "shipped_at"          TIMESTAMP(3),
  ADD COLUMN "delivered_at"        TIMESTAMP(3),
  ADD COLUMN "cancelled_at"        TIMESTAMP(3);
