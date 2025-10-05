# nextjs-cashback

A Next.js App with Tailwind and Playwright tests. Includes a GitHub Actions CI workflow that builds the project and — when Docker is available — builds a Docker image and scans it with Trivy.

## Contents

- `src/app` — Next.js app (App Router)
- `tests` — Playwright tests
- `.github/workflows/ci.yml` — GitHub Actions workflow
- `package.json` — scripts: `dev`, `build`, `start`, `lint`, `test`

## Quick start

1. Install dependencies

```bash
# Reproducible install (recommended)
npm ci

# Or for local development
npm install
```

2. Start development server

```bash
npm run dev
```

Open http://localhost:3000

## Build & run (production)

```bash
# Build
npm run build

# Start the built app
npm run start
```

## Scripts

- `npm run dev` — Start Next.js in development mode
- `npm run build` — Build production app
- `npm run start` — Start production server
- `npm run lint` — Run ESLint
- `npm run test` — Run Playwright tests (`@playwright/test`)

Use the script names above when running locally or in CI.

## Playwright (E2E) notes

The Playwright configuration is in `playwright.config.ts` and includes:

- `testDir: ./tests`
- Reporter: `html`
- Trace: `on-first-retry`
- Projects: `chromium`, `firefox`, `webkit`

Run the full test suite:

```bash
npm run test
```

Run a single test file or with headed browsers:

```bash
npx playwright test tests/example.spec.ts
npx playwright test --headed
npx playwright show-report
```

Note: `webServer` is commented out in the config. If your tests need the local app, either start the dev server before running tests or enable the `webServer` entry.

If Playwright fails due to missing browser binaries, run:

```bash
npx playwright install
```

## CI (GitHub Actions)

Workflow: `.github/workflows/ci.yml`

What it does:

- Runs on push and PR to `main` / `master`.
- Uses Node.js 18 on `ubuntu-latest`.
- Installs dependencies with `npm ci` and runs `npm run build --if-present`.
- Checks whether Docker is available on the runner. If so:
  - Builds a Docker image `nextjs-cashback:ci`.
  - Runs Trivy via `aquasecurity/trivy-action` to scan for CRITICAL/HIGH vulnerabilities and fails the job on results.

Local reproduction of the Docker scan steps (if you have Docker & Trivy installed):

```bash
# Build image
docker build -t nextjs-cashback:ci .

# Scan image with Trivy
trivy image --severity CRITICAL,HIGH nextjs-cashback:ci
```

The workflow will skip Docker/Trivy steps if Docker is not available (this is handy when running the workflow in environments such as `act`).

Note: there is a separate Render deployment workflow at `.github/workflows/production.yml`. It is configured to run only on pushes to the `main` branch and only when certain files change (paths: `src/**`, `package.json`, `pnpm-lock.yaml`, `Dockerfile`, `.github/workflows/**`). This avoids triggering deployments for unrelated edits (docs, CI config, etc.).

## Troubleshooting

- Node version: CI uses Node 18 — use Node 18 locally to match the environment.
- If installation fails, try removing `node_modules` and the lockfile and reinstalling:

```bash
rm -rf node_modules package-lock.json
npm install
```

- If Playwright tests complain about missing browsers:

```bash
npx playwright install
```

## Contributing

- Open a PR against `main`.
- The CI will run automatically. If your changes introduce new production code, ensure tests pass.
