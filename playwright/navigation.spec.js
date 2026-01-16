const { test, expect } = require('@playwright/test');
const config = require('./helpers/config');
const { login } = require('./helpers/auth');

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
      await expect(page).toHaveURL(`${config.baseURL}${destination.path}`);
      await expect(page.getByRole('navigation')).toBeVisible();
    }
  });

  test('samples index shows filter table', async ({ page }) => {
    await page.getByRole('navigation').getByRole('link', { name: 'Sample', exact: true }).click();
    await expect(page).toHaveURL(`${config.baseURL}/stones`);
    await expect(page.locator('table.table.table-striped')).toBeVisible();
    await expect(page.getByRole('link', { name: 'New Entry' })).toBeVisible();
  });

  test('boxes index shows filter table', async ({ page }) => {
    await page.getByRole('navigation').getByRole('link', { name: 'Storageroom/Box', exact: true }).click();
    await expect(page).toHaveURL(`${config.baseURL}/boxes`);
    await expect(page.locator('table.table.table-striped')).toBeVisible();
    await expect(page.getByRole('link', { name: 'New Entry' })).toBeVisible();
  });
});
