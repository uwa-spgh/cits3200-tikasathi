# TikaSathi Developer Guide 🚀

Welcome! This guide is for the team to quickly get up to speed with adding features to the TikaSathi app. We use **Flutter** for UI, and **Riverpod** for state management. 

Don't let the new tech overwhelm you. Keep it simple and follow this guide.

---

## 📂 Where Does My Code Go?

When you start a new feature (e.g. the "Child Profile"), you should create a folder in `lib/features/` and split it into three layers:

- `presentation/`: Your Flutter Widgets (`.dart` files returning UI).
- `domain/`: Your logic and Riverpod Notifiers. 
- `data/`: (Optional) Database queries using Drift.

> [!TIP]
> **Check out the Example Feature**
> We have created an `example_counter` in `lib/features/example_counter` that you can copy and learn from.

---

## 🌊 Riverpod 101 (State Management)

Because we use Riverpod, we don't use `setState()` or `StatefulWidget` very often. Instead, state is managed outside the UI. 

### 1. Creating State (Domain Layer)
We use code-generation to make Riverpod safer and easier. Always use the `@riverpod` annotation.
*(See `lib/features/example_counter/domain/counter_notifier.dart`)*

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0; // The initial state

  void increment() {
    state++; // Updates the state and automatically rebuilds the UI
  }
}
```

### 2. Reading State (Presentation Layer)
To read state in a widget, change your widget from `StatelessWidget` to `ConsumerWidget`. This gives you access to a `WidgetRef` object.
*(See `lib/features/example_counter/presentation/counter_screen.dart`)*

- **`ref.watch()`**: Use this inside the `build()` method to get the current value and trigger UI rebuilds when it changes.
- **`ref.read()`**: Use this inside button `onPressed` callbacks to trigger functions (like `.increment()`) without listening for changes.

---

## 🛠️ The Most Important Command!

Because we use `@riverpod` (and `Freezed` for models), a lot of code is generated for you in the background (files ending in `.g.dart`).

**Whenever you change a Riverpod notifier or add an `@riverpod` annotation, you MUST run this command in your terminal to generate the code:**

```bash
dart run build_runner build --delete-conflicting-outputs
```
*(If you see red squiggly lines saying `.g.dart` is missing, you forgot to run this command!)*

> [!TIP]
> **Pro Tip:** During active development, use `watch` mode instead of `build` so that code regenerates automatically whenever you save a file:
> ```bash
> dart run build_runner watch --delete-conflicting-outputs
> ```

---

## 💾 Local database (pre-release)

We use Drift / SQLite. The file is `tikasathi.sqlite` in the app documents directory.

**Until the first user release, `schemaVersion` stays at 1.** Do not add `onUpgrade` steps for new tables. After you pull a schema change (new table, new column, unique key), wipe your local database so Drift can recreate it:

- Uninstall the app from the simulator/device, or
- Delete `tikasathi.sqlite` and hot-restart

If you skip this, inserts can fail with `no such table` (or a similar schema error).

After we ship to real users, schema changes must bump `schemaVersion` and add an `onUpgrade` migration. Wiping user data will no longer be OK.

---

## 🌐 Localization (EN / NP)

The app supports English and Nepali. Translation strings live in ARB files inside `lib/core/l10n/`:
- `app_en.arb` — English strings
- `app_ne.arb` — Nepali strings

When you add a new user-facing string, add it to **both** ARB files. See Flutter's [Internationalizing Flutter apps](https://docs.flutter.dev/accessibility-and-internationalization/internationalization) guide for more details.

