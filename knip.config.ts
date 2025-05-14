const base = {
  "$schema": "https://unpkg.com/knip@5/schema.json",
  entry: [
    'scripts/*.ts',
  ],
  "project": [
    "**/*.{js,jsx,ts,tsx,mjs,cjs}" // Files Knip should analyze
  ],
  "ignore": [
    "@typescript-eslint/utils/ts-eslint" // Unlisted dependency in eslint.config.ts
  ],
  "ignoreDependencies": [
    // Standard Unused dependencies
    "jiti",
    // "react-dom",
    // Standard Unused devDependencies
    "@types/eslint",
    // "@types/react-dom",
    "@typescript-eslint/eslint-plugin",
    "@typescript-eslint/parser",
    "aiges",
    // "eslint",
    "eslint-config-next",
    "postcss",
    // "prisma",
    "tailwindcss",
    "tw-animate-css", // Imported in css so knip will always false positive
    "server-only" // https://github.com/vercel/next.js/issues/71071
  ],
  "ignoreBinaries": [
    // "next",
    // "tsc",
    // "prisma",
    "prettier"
  ]
} ;
export default base;
