# Features
This directory contains all the distinct features of the application. 
Each feature should ideally be split into:
- `presentation/`: Widgets, screens, and UI-layer Riverpod providers.
- `domain/`: Business logic, models (Freezed), and interfaces.
- `data/`: Repositories and Data sources handling Drift calls.

## Active Features
- `child_profile`: Handling registration and tracking of children.
- `vaccine_schedule`: Calculation of NIP schedules and catch-up logic.
- `education`: Health information and Myth/Fact sheets.
- `facility_locator`: Finding nearby health posts offline.
