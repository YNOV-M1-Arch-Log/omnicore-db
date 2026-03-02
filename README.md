# @omnicore/db

Shared database package for the Omnicore monorepo. Owns the single Prisma schema, all migrations, the seed script, and exports a singleton `PrismaClient` used by every service.

No service maintains its own schema — all models and migrations live here.

## Role in the Monorepo

```
omnicore-db/
  prisma/schema.prisma   ← single source of truth for all models
  prisma/migrations/     ← migration history
  prisma/seed.js         ← seeds the 3 core roles
  src/index.js           ← exports getPrisma / prisma / connectDB / disconnectDB
```

Every service imports the client via the workspace package name:

```js
// CommonJS (gateway, product, order, payment)
const { prisma } = require('@omnicore/db');

// ESM (auth, user)
import { getPrisma } from '@omnicore/db';
const prisma = getPrisma();
```

## Data Models

| Model | Table | Description |
|-------|-------|-------------|
| `Country` | `countries` | Supported countries with currency and active flag |
| `Product` | `products` | Global product catalogue (name, description) |
| `CountryProduct` | `country_products` | Per-country pricing, SKU, stock, and availability |
| `ProductImage` | `product_images` | Product images (URL + optional Cloudinary `public_id`) |
| `Role` | `roles` | RBAC roles (Principal, Tenant, User) |
| `AuthUser` | `auth_users` | Credentials, country assignment, and active flag |
| `AuthSession` | `auth_sessions` | Refresh token records |
| `User` | `users` | User profile linked to `AuthUser` by the same UUID |
| `UserRole` | `user_roles` | Many-to-many join between `AuthUser` and `Role` |
| `UserAddress` | `user_addresses` | Shipping/billing addresses per user |
| `UserPreference` | `user_preferences` | Language, timezone, notification settings |
| `UserAuditLog` | `user_audit_logs` | Action history per user |
| `Order` | `orders` | Order lifecycle (taking + fulfillment fields) |
| `OrderItem` | `order_items` | Line items per order linked to `CountryProduct` |
| `Payment` | `payments` | Stripe payment intent per order |

### Key design decisions

- **`Product` has no price or stock** — those fields live on `CountryProduct` (per-country).
- **`User.id === AuthUser.id`** — the auth service creates the `AuthUser` record; the user service creates the `User` profile using the same UUID.
- **`CountryProduct` is unique on `(productId, countryId)`** — one entry per product per country.

## Available Scripts

Run all scripts from the **monorepo root** using the `--workspace` flag, or `cd` into this directory:

| Script | Command | Description |
|--------|---------|-------------|
| Generate client | `npm run prisma:generate --workspace=@omnicore/db` | Regenerate Prisma Client after schema changes |
| New migration | `npm run prisma:migrate --workspace=@omnicore/db -- --name <name>` | Create and apply a new migration (dev) |
| Deploy migrations | `npm run prisma:migrate:deploy --workspace=@omnicore/db` | Apply pending migrations (production) |
| Prisma Studio | `npm run prisma:studio --workspace=@omnicore/db` | Open the Prisma GUI |
| Seed roles | `npm run seed --workspace=@omnicore/db` | Insert the 3 core roles (idempotent) |

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `NODE_ENV` | `development` enables query logging | No |

Copy `.env.example` to `.env` and fill in `DATABASE_URL` before running any script locally.

## Adding or Modifying Models

1. Edit `prisma/schema.prisma`
2. Create a migration:
   ```bash
   npm run prisma:migrate --workspace=@omnicore/db -- --name <migration_name>
   ```
3. Regenerate the client:
   ```bash
   npm run prisma:generate --workspace=@omnicore/db
   ```
4. The updated client is immediately available to all services via the workspace symlink — no per-service steps needed.

> Do **not** run `prisma generate` inside individual service directories. The per-service `prisma/` directories are stubs and should not be used to manage schema.

## Seeded Roles

The seed script inserts three roles and is safe to run multiple times (checks before inserting):

| Role | Description |
|------|-------------|
| `Principal` | Global admin — full CRUD, can assign/revoke roles |
| `Tenant` | Country-scoped admin — manages products and stock for their assigned country |
| `User` | Read-only — browse products, countries, and stock |

## Docker

In the Docker Compose setup, `omnicore-db` runs as a **one-shot container**: it applies pending migrations and seeds roles, then exits. All other service containers declare:

```yaml
depends_on:
  omnicore-db:
    condition: service_completed_successfully
```

This guarantees the database is fully migrated and seeded before any service starts.

## License

ISC
