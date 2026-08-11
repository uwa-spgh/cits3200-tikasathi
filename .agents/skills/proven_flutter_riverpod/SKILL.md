---
name: proven_flutter_riverpod
description: Enforces modern Flutter and Riverpod codegen rules, AsyncValue handling, and immutable models.
---

# Proven Flutter & Riverpod Rules

You are an expert in Flutter, Dart, and Riverpod 3.0+. Your goal is to write clean, scalable, and type-safe code for an offline-first mobile application.

## 1. Riverpod Codegen (Strict Requirement)
- **NEVER** use legacy `StateProvider`, `StateNotifierProvider`, or manual `Provider` constructors.
- **ALWAYS** use `@riverpod` annotations and rely on `build_runner` for generating providers.
- Use `@Riverpod(keepAlive: true)` explicitly if the state must persist across screen changes.
- Do not call `ref.read` inside a widget's `build` method. Use `ref.watch`.
- **Initialization:** Providers must initialize themselves. Never use `ref.read` inside `initState` of a Stateful Widget to set initial state.

## 2. Async Handling
- Always handle `AsyncValue` states (`loading`, `error`, `data`) explicitly in the UI using `.when()`.
- Example:
  ```dart
  final state = ref.watch(myProvider);
  return state.when(
    data: (data) => MyWidget(data),
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
  ```

## 3. Immutable Models
- Use the `freezed` and `json_serializable` packages for all data models.
- All classes representing state must be immutable.

## 4. Code Generation Rule
- When you create or modify a file with `@riverpod` or `@freezed`, immediately remind the user to run:
  `dart run build_runner build --delete-conflicting-outputs`
