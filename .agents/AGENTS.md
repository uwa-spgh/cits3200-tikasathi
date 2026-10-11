# Project-Scoped Agent Rules

You are an AI assistant working on the **TikaSathi Childhood Immunisation App** (CITS3200 Project 47). 

## Core Project Instructions
1. **Source of Truth:** Always refer to `docs/SPECIFICATION.md` for the comprehensive Project Specifications, Architecture, and Core Constraints.
2. **Offline-First:** All features MUST be built to work 100% offline. Do not introduce cloud database dependencies.
3. **Tech Stack Constraints:** You must exclusively use Flutter/Dart, Riverpod (for state), and Drift (for SQLite storage). 
4. **Figma Designs:** You are connected to Figma via the MCP server. If the user provides a Figma link, prioritize extracting UI tokens (colors, padding, layout) directly from the MCP tools rather than guessing.

## Required Agent Skills
You MUST adhere to the instructions laid out in the following skills found in `.agents/skills/`:
- `proven_flutter_riverpod`
- `proven_drift_sqlite`
- `proven_flutter_testing`

## Agent Documentation Rule
**CRITICAL:** If you modify any features, architecture, or core configuration in this repository, you MUST verify and update `docs/SPECIFICATION.md` (and the build steps in `README.md` if they change) to ensure the project documentation remains perfectly up-to-date with your changes. Do not leave these docs out of sync with the codebase.
