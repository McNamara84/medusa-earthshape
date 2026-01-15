const { test, expect } = require('@playwright/test');

const username = process.env.MEDUSA_E2E_USERNAME || 'admin';
const password = process.env.MEDUSA_E2E_PASSWORD || 'admin123';
const baseURL = process.env.PLAYWRIGHT_BASE_URL || 'http://127.0.0.1:3000';

async function login(page) {
  await page.goto(`${baseURL}/users/sign_in`);
  await page.getByLabel('Username').fill(username);
  await page.getByLabel('Password').fill(password);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.locator('a[title="logout"]')).toBeVisible();
}

test.describe('Primary navigation', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('navbar destinations render', async ({ page }) => {
    const destinations = [
      { label: 'View all entries', path: '/records' },
      { label: 'Map', path: '/' },
      { label: 'Sampling Campaign', path: '/collections' },
      { label: 'Sampling Location', path: '/places' },
      { label: 'Storageroom/Box', path: '/boxes' },
      { label: 'Sample', path: '/stones' },
      { label: 'Analysis', path: '/analyses' },
      { label: 'File', path: '/attachment_files' },
      { label: 'Bibliography', path: '/bibs' },
      { label: 'Import of CSV', path: '/stagings' },
    ];

    for (const destination of destinations) {
      await page.getByRole('link', { name: destination.label }).click();
      const pathPattern = destination.path.replace(/\//g, '\\/');
      await expect(page).toHaveURL(new RegExp(`${baseURL}${pathPattern}`));
      await expect(page.getByRole('navigation')).toBeVisible();
    }
  });

  test('samples index shows filter table', async ({ page }) => {
    await page.getByRole('link', { name: 'Sample' }).click();
    await expect(page).toHaveURL(new RegExp(`${baseURL}/stones`));
    await expect(page.locator('table.table.table-striped')).toBeVisible();
    await expect(page.getByRole('link', { name: 'New Entry' })).toBeVisible();
  });

  test('boxes index shows filter table', async ({ page }) => {
    await page.getByRole('link', { name: 'Storageroom/Box' }).click();
    await expect(page).toHaveURL(new RegExp(`${baseURL}/boxes`));
    await expect(page.locator('table.table.table-striped')).toBeVisible();
    await expect(page.getByRole('link', { name: 'New Entry' })).toBeVisible();
  });
});
