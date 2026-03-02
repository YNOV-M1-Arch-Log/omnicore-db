# omnicore-db — one-shot migration & seed runner
# This container runs `prisma migrate deploy` + `node prisma/seed.js` then exits.
# All other services declare `depends_on: omnicore-db: condition: service_completed_successfully`.

FROM node:22-alpine

WORKDIR /app

# ── Workspace metadata (needed for npm ci to resolve the workspace graph) ──
COPY package.json package-lock.json ./
COPY omnicore-db/package.json      ./omnicore-db/package.json
COPY omnicore-auth/package.json    ./omnicore-auth/package.json
COPY omnicore-user/package.json    ./omnicore-user/package.json
COPY omnicore-product/package.json ./omnicore-product/package.json
COPY omnicore-gateway/package.json ./omnicore-gateway/package.json
COPY omnicore-order/package.json   ./omnicore-order/package.json
COPY omnicore-payment/package.json ./omnicore-payment/package.json

# ── Full source of the shared package ──
COPY omnicore-db/ ./omnicore-db/

# Install all deps including devDeps (prisma CLI needed for migrate deploy + generate)
RUN npm ci && npm cache clean --force

# Generate Prisma client so seed.js can use @prisma/client
RUN cd omnicore-db && npx prisma generate

WORKDIR /app/omnicore-db

# Apply pending migrations then seed reference data
CMD ["sh", "-c", "npx prisma migrate deploy && node prisma/seed.js"]
