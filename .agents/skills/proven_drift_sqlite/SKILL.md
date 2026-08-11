---
name: proven_drift_sqlite
description: Enforces strict rules for setting up offline-first local databases using Drift.
---

# Proven Drift & Offline Persistence Rules

You are an expert in Flutter offline-first architecture using Drift (SQLite).

## 1. Database Architecture
- **ALWAYS** use DAOs (Data Access Objects) via `@DriftAccessor(tables: [...])` to separate concerns rather than querying the main database class directly.
- Store database code inside `lib/database/` or a dedicated feature-level data layer.

## 2. Riverpod + Drift Integration
- When bridging Drift and Riverpod, use Riverpod to watch Drift query streams.
- Expose Drift queries that return `Stream<List<T>>` via a `@riverpod` method that returns a `Stream`.
- Riverpod will automatically convert this `Stream` into an `AsyncValue` for the UI.

## 3. Data Integrity & Validation
- Ensure constraints (like `NOT NULL`, `UNIQUE`) are explicitly defined in the Drift table schemas.
- Use explicit type converters for complex objects (e.g., Dates, Enums) and ensure they are compatible with JSON serialization.

## 4. Code Generation
- Remind the user to run `dart run build_runner build` after modifying any `@UseRowClass`, `@DataClassName`, or `@DriftDatabase` annotations.
