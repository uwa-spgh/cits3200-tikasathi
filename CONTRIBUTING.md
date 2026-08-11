# Contributing to TikaSathi

Welcome to the team! This document covers our Git workflow and conventions.

## Git Branching Strategy

We use a **feature-branch workflow** with two protected branches:

```
main          ← Production-ready code. Never push directly.
  └── develop ← Integration branch. PRs merge here first.
        ├── feature/child-profile
        ├── feature/vaccine-schedule
        ├── fix/date-validation-crash
        └── chore/update-dependencies
```

### Branch Naming Convention

| Prefix | Use When |
|---|---|
| `feature/` | Adding a new feature (e.g. `feature/child-registration`) |
| `fix/` | Fixing a bug (e.g. `fix/dob-future-date`) |
| `chore/` | Non-functional work like dependency updates or CI changes |
| `docs/` | Documentation-only changes |

### Workflow

1. **Create a branch** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit with clear messages:
   ```bash
   git add .
   git commit -m "feat: add child registration form"
   ```

3. **Before pushing**, run the CI checks locally:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

4. **Push and open a PR** against `develop`:
   ```bash
   git push origin feature/your-feature-name
   ```
   Then open a Pull Request on GitHub targeting `develop`. Fill in the PR template.

5. **Get at least 1 review** before merging.

6. **`develop` → `main`** merges happen at the end of each sprint after team review.

## Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) prefixes:

- `feat:` — A new feature
- `fix:` — A bug fix
- `docs:` — Documentation changes
- `chore:` — Maintenance tasks (CI, deps, configs)
- `test:` — Adding or updating tests
- `refactor:` — Code changes that neither fix a bug nor add a feature

## Code Generation

This project uses `build_runner` for Riverpod, Freezed, and Drift codegen. If you modify any file containing `@riverpod`, `@freezed`, or Drift annotations, you **must** regenerate before committing:

```bash
dart run build_runner build --delete-conflicting-outputs
```

We **commit generated `.g.dart` and `.freezed.dart` files** to the repo so teammates don't need to run build_runner after every pull.
