const { test, expect } = require('@playwright/test');

const username = process.env.MEDUSA_E2E_USERNAME || process.env.MEDUSA_ADMIN_USERNAME || 'admin';
const password =
  process.env.MEDUSA_E2E_PASSWORD ||
  process.env.MEDUSA_ADMIN_PASSWORD ||
  'vQxPIFMZ';

// Basic sanity check that a seeded user can sign in and reach the main search page.
test('sign in and view search maps', async ({ page }) => {
  await page.goto('/users/sign_in');

  // Rails form_for generates: <input id="user_username" name="user[username]" ...>
  await page.locator('#user_username').fill(username);
  await page.locator('#user_password').fill(password);
  await page.getByRole('button', { name: 'Sign in' }).click();

  await page.waitForLoadState('networkidle');

  await expect(page).toHaveURL(/(\/search_maps|\/)$/);
  await expect(page.locator('a[title="logout"]')).toBeVisible();
  await expect(page.locator('form[action="/search_maps"]')).toBeVisible();
});
