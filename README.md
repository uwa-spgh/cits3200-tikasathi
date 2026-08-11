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

## 7. Getting Started for Developers

Welcome to the team! Follow these instructions to get your local environment ready for this project:

### 1. Install Flutter
If you haven't already, install the [Flutter SDK](https://docs.flutter.dev/get-started/install). Ensure that `flutter doctor` runs cleanly on your machine.

### 2. Fetch Dependencies
This project uses a custom scaffold. Run the following command in the root of the project to fetch all required dependencies (Riverpod, Drift, Freezed, etc.):
```bash
flutter pub get
```
> [!WARNING]
> **Windows Users:**
> Flutter requires symlink support to build plugins. You must enable **Developer Mode** in Windows before running `flutter pub get`. 
> 1. Open your terminal and run `start ms-settings:developers`
> 2. Toggle **Developer Mode** ON.

### 3. Setup Figma AI Integration
We use AI agents to translate Figma designs into Flutter code. To give your IDE access to our Figma files:
1. Open your IDE's `mcp_config.json` file.
2. Add the following Figma configuration, replacing the token with your own Personal Access Token:
```json
"figma": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-figma"],
  "env": {
    "FIGMA_ACCESS_TOKEN": "YOUR_FIGMA_PERSONAL_ACCESS_TOKEN"
  }
}
```
