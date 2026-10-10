import { cloudflareTest, readD1Migrations } from '@cloudflare/vitest-pool-workers';
import { defineConfig } from 'vitest/config';

export default defineConfig(async () => {
  const migrations = await readD1Migrations('./migrations');
  return {
    plugins: [
      cloudflareTest({
        main: './src/index.ts',
        wrangler: { configPath: './wrangler.toml' },
        miniflare: {
          // Faqat sinov qiymatlari (haqiqiy secretlar emas).
          bindings: {
            TEST_MIGRATIONS: migrations,
            LG_SERVER_SECRET: 'test-only-secret-0123456789abcdef0123456789',
            BREVO_API_KEY: 'test-brevo-key',
            LG_SENDER_EMAIL: 'noreply@example.test',
            LG_ADMIN_EMAILS: 'boss@example.test',
          },
        },
      }),
    ],
    test: {
      setupFiles: ['./test/setup.ts'],
    },
  };
});
