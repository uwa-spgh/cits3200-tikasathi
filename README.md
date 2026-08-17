# TikaSathi
An mHealth application for childhood immunisation reminders and information.

Created as a final year UWA CITS3200 project in conjunction with The UWA School of [Population and Global Health](https://www.uwa.edu.au/schools/population-global-health).

---

# Project Specification

This document outlines the detailed specifications, architecture, and technology stack for the Childhood Immunisation App for Nepal (Team 47, CITS3200). It serves as the single source of truth for the development team before any code is written.

## 1. Project Overview
The goal is to build an mHealth application for mothers and caregivers in low-resource, rural areas of Nepal. The app tracks children's immunisation schedules, provides timely reminders, and offers health education. 

> [!IMPORTANT]
> **Core Constraints**
> - **Offline-First:** The app must function entirely offline. Connectivity is only used for opportunistic background syncing or live maps.
> - **Hardware:** Must run smoothly on low-end, inexpensive Android and iOS devices with limited RAM and older OS versions.
> - **Literacy & Accessibility:** Target users have varying literacy levels. The UI must heavily favour icons, large touch targets, and use simple language.
> - **Privacy:** Sensitive health and location data must be encrypted locally using device-native security (PIN/Biometrics).

## 2. Technology Stack
Based on the project constraints and team requirements, the following tech stack will be used:

* **UI & Framework:** **Flutter (Dart)**. Flutter is highly performant on low-end hardware, natively compiles to both iOS and Android, and allows for a single unified codebase.
* **Flutter Version Management:** **FVM** pins the project to Flutter 3.44.9, so every developer and the CI pipeline use a compatible Flutter and Dart toolchain.
* **State Management:** **Riverpod**. A compile-safe, scalable state management solution that will handle the app's complex reactive state (e.g., updating UI instantly when a vaccine is marked completed).
* **Local Database:** **Drift**. A reactive, type-safe SQLite library for Flutter. It is perfect for local data storage and offline-first persistence.
* **Notifications:** `flutter_local_notifications` to interface with the device's native calendar and notification APIs for the 3-touch reminder system (1 week before, 1 day before, day-of).
* **Localization:** Flutter's built-in `flutter_localizations` combined with JSON or ARB files to support instant toggling between English (EN) and Nepali (NP).
* **Security:** `flutter_secure_storage` and `local_auth` for encrypting data at rest and locking the app behind biometrics/PIN.

## 3. CI/CD & Testing Strategy
To maintain code quality across the 6-person team, all pull requests will be subjected to a strict CI/CD pipeline using **GitHub Actions**.

### GitHub Actions Workflow
Every pull request to the `main` or `develop` branch will trigger a workflow that runs:
1. **Formatting & Linting:** `dart format --set-exit-if-changed .` and `flutter analyze` to ensure code style consistency.
2. **Unit Tests:** `flutter test` to verify the logic of the age calculator, vaccine schedule generator, and missed-dose catch-up algorithm.
3. **Widget Tests:** Automated UI tests to ensure critical flows (e.g., child registration, language toggling) render correctly without regressions.

> [!TIP]
> **Project Acceptance Tests**
> Your team will also perform manual Acceptance Testing on physical low-end devices to verify the app meets the criteria outlined in `Project Acceptance Tests.md`, such as:
> - Ensuring language switching takes fewer than 5 actions.
> - Verifying notifications arrive even when the app is force-closed.
> - Confirming child profiles persist completely offline.

## 4. Core Modules & Data Architecture

### Child Profile Management
- Store UUID, Name, DOB, Sex, Caregiver details, and Ward Number.
- **Validation:** Gracefully handle future dates or invalid inputs.

### Immunisation Engine
- Automatically calculate age and generate the vaccine schedule (BCG, Pentavalent, Rotavirus, PCV, etc.) based on the Nepal NIP schedule.
- **Statuses:** Upcoming (○), Completed (✓), Overdue (⚠).
- **Catch-up Logic:** Complex rules for adjusting intervals if a dose is missed.

### Notification System
- Native, offline-scheduled notifications based on exact clinical intervals. 
- Automatically fallback to periodic (fortnightly) alerts for overdue vaccines to prevent reminder fatigue.

### Health Information & Facility Locator
- Educational modules containing Myth/Fact sections (adapted from Nepal's Family Welfare Division).
- A directory of local health posts (स्वास्थ्य चौकी), filterable and searchable offline.

## 5. Integrating Figma Designs

Because the **Figma MCP Server** has been successfully configured in the workspace, AI agents can now connect directly to your Figma files!

> [!NOTE]
> **How to use Figma with AI Agents:**
> You no longer need to export screens manually. Simply provide the AI agent with your **Figma File URL** or **Node ID**, and the agent will use the MCP server to directly extract the design tokens, layout hierarchy, and SVG assets required to build the UI in Flutter.

## 6. AI Agent Guidelines & Custom Skills

This repository is equipped with custom, community-proven AI steering skills located in the `.agents/skills/` directory. All AI assistants working on this codebase will automatically inherit and enforce these rules:

- **proven_flutter_riverpod:** Mandates modern `@riverpod` codegen and strict immutable models using `freezed`.
- **proven_drift_sqlite:** Enforces offline-first Data Access Objects (DAOs) and watching database streams natively with Riverpod.
- **proven_flutter_testing:** Enforces `ProviderScope` wrapping for widget tests and mandates running CI checks locally before submitting code.

## 7. Quick Start Guide for Developers

Welcome to the team! Follow this step-by-step Quick Start guide to set up your local environment and begin feature development:

### Step 1: Prerequisites & SDK Setup
1. Install [FVM](https://fvm.app/documentation/getting-started/installation), the Flutter Version Manager.
2. From the project root, install the Flutter version pinned in `.fvmrc`:
   ```bash
   fvm install
   ```
3. Verify the development environment:
   ```bash
   fvm flutter doctor
   ```
4. > [!WARNING]
   > **Windows Users:**
   > Flutter requires symlink support to build plugins. You **must** enable **Developer Mode** in Windows before fetching dependencies:
   > 1. Open your terminal and run `start ms-settings:developers`
   > 2. Toggle **Developer Mode** to **ON**.

### Step 2: Fetch Dependencies
Run the following command in the project root:
```bash
fvm flutter pub get
```

### Step 3: Start Code Generation (Watch Mode)
We use `build_runner` for Riverpod state providers (`.g.dart`), Freezed models, and Drift SQLite databases.
During active development, run build_runner in **watch mode** so generated files update automatically whenever you save a file:
```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```
*(Alternatively, for a single manual build pass, run: `fvm dart run build_runner build --delete-conflicting-outputs`)*

### Step 4: Explore the Reference Feature
If you are new to Flutter or Riverpod, examine the `example_counter` feature before writing new code:
* **UI Screen:** [counter_screen.dart](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/lib/features/example_counter/presentation/counter_screen.dart) — Shows `ConsumerWidget`, `ref.watch()` for UI rebuilds, and `ref.read()` for button actions.
* **State Logic:** [counter_notifier.dart](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/lib/features/example_counter/domain/counter_notifier.dart) — Demonstrates modern `@riverpod` annotations.
* **Tests:** [counter_notifier_test.dart](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/test/features/example_counter/domain/counter_notifier_test.dart) & [counter_screen_test.dart](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/test/features/example_counter/presentation/counter_screen_test.dart).
* **Crash Course:** Read [DEVELOPER_GUIDE.md](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/DEVELOPER_GUIDE.md) for a 5-minute Flutter & Riverpod 101 summary.

### Step 5: Verify Locally Before Committing
Before opening a Pull Request, verify your changes locally using the same checks enforced by GitHub Actions:
```bash
fvm dart format .
fvm flutter analyze
fvm flutter test
```

### Step 6: Git Workflow & Figma Integration
* **Branching Strategy:** Review [CONTRIBUTING.md](file:///c:/Users/tobyf/Desktop/cits3200-tikasathi/CONTRIBUTING.md) for `feature/`, `fix/`, and `chore/` branch naming and Conventional Commit rules.
* **Figma MCP Server:** If configured in your IDE, AI agents can extract design tokens directly from Figma links. Configure `@modelcontextprotocol/server-figma` in your `mcp_config.json` with your `FIGMA_ACCESS_TOKEN`.

