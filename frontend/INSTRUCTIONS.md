# Development Instructions

This document defines the mandatory standards for developing in this project. Follow all instructions below when building new features, components, or making adjustments.

---

## Project Architecture

This project follows a **feature-based architecture with a shared layer**, structured as:

```
src/
├── app/
│   ├── router/         # Vue Router configuration and navigation guards
│   └── init.ts         # Bootstrap logic that runs before the app mounts
│
├── modules/            # Feature-isolated modules (the core of the project)
│   ├── auth/
│   │   ├── pages/      # Page-level components for this module
│   │   ├── services/   # HTTP calls scoped to this module
│   │   └── stores/     # Pinia stores scoped to this module
│   ├── student/
│   ├── teacher/
│   ├── company/
│   ├── home/
│   └── schemas/        # Zod validation schemas shared across modules
│
└── shared/
    ├── components/     # Reusable generic components (BaseInput, ToastContainer, etc.)
    ├── composables/    # Reusable composition logic (useForm, etc.)
    ├── layouts/        # Page layouts (AppLayout)
    ├── services/       # Shared services (the Axios instance)
    └── stores/         # Global stores (ui.store, toast.store)
```

**Golden rules:**

- A module must not import from another module. If something needs to be shared between modules, move it to `shared/`.
- `shared/` is an internal library - only put things there that are genuinely reusable.
- Page-level components live in `modules/<feature>/pages/`. Reusable UI components live in `shared/components/`.

---

## Code Language and Comments

- All code must be written in **English**: variable names, function names, type names, file names, constants, and all identifiers.
- **UI text displayed to the user** (labels, buttons, placeholders, toast messages, headers, error messages, and any other visible text) must be written in **Portuguese**.
- **No comments are allowed anywhere in the codebase** - no `//`, no `/* */`, no template comments. Code must be self-explanatory through naming and structure alone.
- If the logic is unclear without a comment, refactor it until it is clear.

---

## Naming and Files

- File names follow the pattern `kebab-case.ts` for scripts and `PascalCase.vue` for components.
- Page components are suffixed with `Page` (e.g., `LoginPage.vue`, `StudentDashboardPage.vue`).
- Store files are suffixed with `.store.ts` (e.g., `auth.store.ts`, `ui.store.ts`).
- Service files are suffixed with `.service.ts` (e.g., `auth.service.ts`).
- Schema files are suffixed with `.schema.ts` (e.g., `login.schema.ts`).
- Avoid generic variable names like `data`, `info`, `temp`, or `res`. Use descriptive, context-specific names.
- Always use full TypeScript typing. No `any`, no untyped functions, no untyped props.

---

## Vue Components

- All components use `<script setup lang="ts">` - the modern Composition API syntax.
- Define props with `defineProps<{}>()` using a TypeScript interface inline.
- Define emits with `defineEmits<{}>()` using typed signatures.
- Keep `App.vue` as a shell - no logic, no styles, only global component rendering and `<router-view />`.
- Prefer `ref` over `reactive` for consistency. Access reactive values with `.value` in the script; the template unwraps automatically.
- Use `computed` for derived state - never recalculate values inline in the template.

---

## Styling and Colors

- Never use hardcoded color values (e.g., `#fff`, `rgb(0,0,0)`) directly in components.
- Never use Tailwind color utilities that reference specific palette values (e.g., `text-red-500`, `bg-gray-900`). Use CSS custom properties instead.
- Always use the design tokens defined in `src/style.css` via inline `style` bindings or CSS custom property references:

```
--color-primary        --color-primary-dark     --color-primary-light
--color-bg             --color-surface          --color-surface-hover
--color-sidebar-bg     --color-sidebar-hover    --color-sidebar-muted
--color-text           --color-text-muted
--color-border         --color-danger           --color-success
--color-warning        --color-info
--radius               --radius-lg
--shadow               --shadow-lg
```

- Use the pre-built utility classes from `src/style.css` whenever applicable: `.btn`, `.btn-secondary`, `.btn-danger`, `.card`, `.input`, `.nav-link`, `.nav-link--active`, `.badge`, `.badge-primary`, `.badge-success`, `.badge-danger`, `.text-muted`, `.text-primary`.
- Do not add new CSS custom properties without prior alignment.
- Use Tailwind only for layout, spacing, flexbox, grid, and sizing utilities.

---

## State Management (Pinia)

- Each module that needs state owns its store inside `modules/<feature>/stores/`.
- Global UI state lives in `shared/stores/ui.store.ts` (loading indicator) and `shared/stores/toast.store.ts` (notifications).
- Use the **Setup Store** pattern with `defineStore('id', () => { ... })` - mirrors the Composition API.
- Expose only what consumers need from the store's return value.
- Never mutate another module's store directly. Go through its exposed actions.

---

## HTTP Requests (Axios)

- Always use the pre-configured Axios instance exported from `shared/services/api.ts`. Never create a new `axios.create()` instance.
- Scope HTTP functions to their module's service file (e.g., `modules/auth/services/auth.service.ts`).
- Service functions must be plain functions that return the Axios promise - no state management inside services.
- The `api.ts` interceptors automatically handle the global loading state and error toasts. Do not replicate that logic in components or stores.
- All API base URLs come from the `VITE_API_URL` environment variable defined in `.env`. Never hardcode URLs.

---

## Form Validation (Zod)

- Define all form schemas in `modules/schemas/` using Zod.
- Always infer the TypeScript type from the schema using `z.infer<typeof schema>` - never declare the type separately.
- Use the `useForm` composable from `shared/composables/useForm.ts` to handle form state and validation.
- Validation runs on submit, not on every keystroke.

---

## Routing

- Route definitions live in `src/app/router/routes.ts`.
- Protect authenticated routes with `meta: { requiresAuth: true }`.
- Use lazy-loaded imports (`() => import(...)`) for all page components to enable code splitting.
- Navigate programmatically using `useRouter().push({ name: 'route-name' })` - prefer named routes over hardcoded paths.
- The navigation guard in `src/app/router/index.ts` handles auth redirects automatically based on `useAuthStore().isAuthenticated`.

---

## Environment Variables

- All environment variables must be prefixed with `VITE_` to be available on the client.
- Access them via `import.meta.env.VITE_VARIABLE_NAME`.
- Never commit secrets or private keys in `.env` files.

---

## Documentation

- Avoid creating documentation files. Only create one if it is strictly necessary.
- If a documentation file must be created, use Markdown (`.md`) and place it inside the `docs/` folder.

---

## General Best Practices

- Before committing, run `npm run dev` to confirm the application works and `npm run format` to enforce code style.
- Do not add new dependencies without a real need and without validating the package's size and maintenance status.
- Do not change the folder structure without prior alignment.
- Keep components small and focused on a single responsibility.
- Prefer early returns to reduce nesting.
- When in doubt, refer back to this document or ask for a review before implementing something outside the established pattern.
