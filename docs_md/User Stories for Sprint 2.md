# User Stories for Sprint 2

I’ve written these with the Connextra template because I think it makes them very clear to understand. https://agilealliance.org/glossary/user-story-template/

## User Story 1: Secure Offline Child Registration

As a mother/caregiver,

I want to create a profile for my child with their name and date of birth,

So that I can track their specific immunisation needs without relying on an internet connection

Acceptance Criteria

the app needs to use a local storage solution to save the childs ID (UUID), name, date of birth, and sex

we have to make sure the database is encrypted at rest using the device secure storage or biometric APIs

it should be possible to do the whole registration flow entirely offline without needing any external network connections

if someone enters an invalid date of birth like a future date, the input form should gracefully handle it

closing and reopening the application has to completely retain the registered childs profile data securely

## User Story 2: Automated Schedule Generation

As a mother/caregiver,

I want the app to automatically calculate my child's vaccination schedule based on their birth date,

So that I know exactly when vaccines like BCG, Pentavalent, and MR are due

Acceptance Criteria

it should automatically create VaccinationRecord objects that strictly follow the official Nepal National Immunisation Programme schedule

the system needs to calculate the childs exact age in weeks, months or years by grabbing the built in date and time from the device

each vaccine record generated will default to an Upcoming, Due or Overdue status depending on how the current date compares to the calculated due date

## User Story 3: Recording Vaccination Completion

As a health worker or caregiver,

I want to mark a specific scheduled vaccination as completed in the app,

So that I can maintain an accurate, up-to-date history of the child's immunisations

Acceptance Criteria

users should be able to just tap on a scheduled vaccine to mark it as completed

once a vaccine is marked done, the status enum needs to change to Completed and it should safely record the completedDate

the interface has to update instantly to show the completed status using clear visual indicators like checkmarks without needing to refresh the screen

## User Story 4: English/Nepali Language Toggle

As a mother/caregiver,

I want to switch the app's text between English and Nepali at any time,

So that I can clearly understand the health information regardless of my language proficiency

Acceptance Criteria

there should be a highly visible language toggle button for EN/NP that takes less then 5 actions to reach from any screen

the app needs to pull static text from separate local JSON translation files for both English and Nepali

hitting the toggle should instantly update all the interface text with minimal semantic changes while ignoring user inputted strings like the childs name

it has to save the selected language locally in the UserSettings object so it remembers it

## User Story 5: Offline Immunisation Education

As a mother/caregiver,

I want to read offline information about why vaccines are important and common side effects,

So that I can feel confident and informed about vaccinating my child

Acceptance Criteria

we need to make sure the education module explicitly includes sections covering Why Vaccines Are Important, Common Side Effects, and a Myth and Fact breakdown

all this educational text needs to be bundled right into the application package so its fully accessible without any network connection

finding the education section, searching for a topic and then exiting should each take fewer then 5 actions

## Everything Else

To finish up this project in the last sprint, development is going to need to shift towards actual final device specific integrating and the more complicated logic:

we need to implement the 3 touch reminder approach with alerts one week before, one day before and on the day by using the devices native calendar and notification APIs so that notifications trigger even if the app is closed

building the actual decision engine logic to handle missed doses, update statuses to Overdue and recalculate the minimum intervals for vaccines

adding an offline capable list and search functions so users can find nearby health posts and primary health care centres

creating a simple local backup feature for export and import to help mitigate data loss just in case a device gets damaged or replaced

finalising the short in app onboarding flow, writing up the developer README and finishing the handover document