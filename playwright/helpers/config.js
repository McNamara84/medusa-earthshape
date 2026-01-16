/**
 * Shared configuration for Playwright E2E tests.
 *
 * Credentials are read from environment variables with fallback defaults.
 * In CI, set MEDUSA_E2E_USERNAME and MEDUSA_E2E_PASSWORD (or MEDUSA_ADMIN_*).
 * The fallback password matches config/application.yml.example for local development.
 */

const config = {
  username: process.env.MEDUSA_E2E_USERNAME || process.env.MEDUSA_ADMIN_USERNAME || 'admin',
  password: process.env.MEDUSA_E2E_PASSWORD || process.env.MEDUSA_ADMIN_PASSWORD || 'vQxPIFMZ',
  baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://127.0.0.1:3000',
};

module.exports = config;
