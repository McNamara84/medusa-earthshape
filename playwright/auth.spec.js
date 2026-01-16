const { test, expect } = require('@playwright/test');

const username = process.env.MEDUSA_E2E_USERNAME || process.env.MEDUSA_ADMIN_USERNAME || 'admin';
const password =
  process.env.MEDUSA_E2E_PASSWORD ||
  process.env.MEDUSA_ADMIN_PASSWORD ||
  'vQxPIFMZ';

// Basic sanity check that a seeded user can sign in and reach the main search page.
test('sign in and view search maps', async ({ page }) => {
  await page.goto('/users/sign_in');

  // Debug: log the page content if login fails
  console.log(`Attempting login with username: ${username}`);

  // Use more specific selectors that match the Rails form_for output
  // Rails form_for generates: <input id="user_username" name="user[username]" ...>
  await page.locator('#user_username').fill(username);
  await page.locator('#user_password').fill(password);

  // Take a screenshot before clicking to debug
  await page.screenshot({ path: 'test-results/before-login.png' });

  await page.getByRole('button', { name: 'Sign in' }).click();

  // Wait for navigation and check URL
  // If login fails, Rails will redirect back to /users/sign_in with a flash error
  await page.waitForLoadState('networkidle');

  // Take a screenshot after clicking for debugging
  await page.screenshot({ path: 'test-results/after-login.png' });

  // Check if there's an error message visible
  const errorMessage = page.locator('.alert, .notice, .error, .flash');
  if (await errorMessage.count() > 0) {
    console.log('Flash message found:', await errorMessage.textContent());
  }

  // Log current URL for debugging
  console.log('Current URL after login attempt:', page.url());

  await expect(page).toHaveURL(/(\/search_maps|\/)$/);
  await expect(page.locator('a[title="logout"]')).toBeVisible();
  await expect(page.locator('form[action="/search_maps"]')).toBeVisible();
});
