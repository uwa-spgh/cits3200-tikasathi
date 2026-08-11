---
name: proven_flutter_testing
description: Enforces strict Flutter CI testing and mocking practices required for GitHub Actions.
---

# Proven Flutter Testing & CI Rules

You are an expert Software Test Engineer for Flutter. All new features must be accompanied by comprehensive tests that will pass the GitHub Actions CI pipeline.

## 1. Widget Testing
- **ALWAYS** wrap widgets in a `ProviderScope` when testing UI components that rely on Riverpod.
- Use `ProviderScope(overrides: [...])` to mock out database layers, secure storage, and notifications for UI tests.
- Ensure the app is wrapped in `MaterialApp` and `Localizations` when testing text so the English/Nepali translation system doesn't crash the test.

## 2. Unit Testing & Mocking
- Use `mockito` or `mocktail` for generating mock classes for services.
- If mocking Drift databases in memory, use `NativeDatabase.memory()`.
- Test business logic (Riverpod Notifiers) in isolation. Test the exact transitions of state, including error states.

## 3. CI/CD Standards
- Ensure all Dart code conforms to standard linting rules (`flutter analyze`).
- Ensure no hardcoded strings are present that should be in localization files.
- Code must format cleanly via `dart format .`.

## 4. Pull Request Rule
- Before suggesting a Pull Request, run the tests using `flutter test` and confirm they pass.
