-- Migration: add sku column to country_products
ALTER TABLE "country_products" ADD COLUMN "sku" VARCHAR(100);

