const { test, expect } = require('@playwright/test');

const username = process.env.MEDUSA_E2E_USERNAME || 'admin';
const password = process.env.MEDUSA_E2E_PASSWORD || 'admin123';

// Basic sanity check that a seeded user can sign in and reach the main search page.
test('sign in and view search maps', async ({ page }) => {
  await page.goto('/users/sign_in');

  await page.getByLabel('Username').fill(username);
  await page.getByLabel('Password').fill(password);
  await page.getByRole('button', { name: 'Sign in' }).click();

  await expect(page).toHaveURL(/(\/search_maps|\/)$/);
  await expect(page.locator('a[title="logout"]')).toBeVisible();
  await expect(page.locator('form[action="/search_maps"]')).toBeVisible();
});
