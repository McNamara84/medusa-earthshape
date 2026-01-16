/**
 * Shared authentication helpers for Playwright E2E tests.
 */

const { expect } = require('@playwright/test');
const config = require('./config');

/**
 * Log in to the application using the configured credentials.
 * @param {import('@playwright/test').Page} page - Playwright page object
 */
async function login(page) {
  await page.goto(`${config.baseURL}/users/sign_in`);
  // Rails form_for generates: <input id="user_username" name="user[username]" ...>
  await page.locator('#user_username').fill(config.username);
  await page.locator('#user_password').fill(config.password);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForLoadState('networkidle');
  await expect(page.locator('a[title="logout"]')).toBeVisible({ timeout: 15000 });
}

module.exports = { login };
