-- Stripe Payment records — one per order, tracks the full payment lifecycle

CREATE TABLE "payments" (
  "id"                       TEXT          NOT NULL,
  "order_id"                 TEXT          NOT NULL,
  "stripe_payment_intent_id" VARCHAR(255)  NOT NULL,
  "stripe_client_secret"     TEXT          NOT NULL,
  "amount"                   DECIMAL(10,2) NOT NULL,
  "currency"                 VARCHAR(10)   NOT NULL,
  "status"                   VARCHAR(50)   NOT NULL DEFAULT 'pending',
  "failure_reason"           TEXT,
  "refund_id"                VARCHAR(255),
  "refund_reason"            TEXT,
  "paid_at"                  TIMESTAMP(3),
  "failed_at"                TIMESTAMP(3),
  "refunded_at"              TIMESTAMP(3),
  "created_at"               TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at"               TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "payments_order_id_key"                 ON "payments"("order_id");
CREATE UNIQUE INDEX "payments_stripe_payment_intent_id_key" ON "payments"("stripe_payment_intent_id");
CREATE        INDEX "payments_status_idx"                   ON "payments"("status");
CREATE        INDEX "payments_stripe_payment_intent_id_idx" ON "payments"("stripe_payment_intent_id");
