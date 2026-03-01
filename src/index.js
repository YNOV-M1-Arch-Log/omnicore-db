'use strict';

const { PrismaClient } = require('@prisma/client');
const { PrismaPg }     = require('@prisma/adapter-pg');

let _prisma = null;

/**
 * Returns the singleton PrismaClient, creating it on first call.
 * Lazy initialization ensures DATABASE_URL is set (via dotenv) before the
 * client is constructed — safe for both CJS and ESM import orders.
 */
const getPrisma = () => {
  if (!_prisma) {
    const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
    _prisma = new PrismaClient({
      adapter,
      log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
    });
  }
  return _prisma;
};

const connectDB = async () => {
  await getPrisma().$connect();
};

const disconnectDB = async () => {
  if (_prisma) await _prisma.$disconnect();
};

// Build the exports object and expose `prisma` as a getter so destructuring works:
//   const { prisma } = require('@omnicore/db')   → calls getPrisma() on first access
const exports_ = { getPrisma, connectDB, disconnectDB };

Object.defineProperty(exports_, 'prisma', {
  get: getPrisma,
  enumerable: true,
  configurable: true,
});

module.exports = exports_;
