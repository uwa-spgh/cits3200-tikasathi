Scope of Work

Project: Developing an mHealth application (app) for childhood immunisation in Nepal

Client/Mentor Group: Associate Professor Julie Saunders, Sadia Tasnim, Brett Roper

Group Number: 47

General Goals

The goal of this system is to help mothers and caregivers in low-resource, hilly rural areas of Nepal track their children’s immunisation schedules and receive timely reminders, without depending on internet connectivity, literacy, or regular facility visits. The system aims to reduce missed or delayed vaccinations by making the schedule and reminders visible directly on a caregiver’s own device.

Increase the proportion of on time vaccinations by surfacing the schedule and reminders directly to caregivers

Provide an interface usable by caregivers with low or no literacy, in both English and Nepali Language

Protect sensitive child health data through local encryption

Deliver a working and well-documented open-source pilot the client can trial in a large sample

Current System

Immunisation tracking in the target communities currently relies on paper-based child health booklets (similar in purpose to the Australian blue/purple child health books), completed and kept by hand by caregivers or local health workers. Moreover, reminders for upcoming vaccinations are informal, typically word-of-mouth from health workers rather than scheduled or automated. This approach is vulnerable to loss or damage, gives no proactive reminders, and offers no easy way to track multiple children individually beyond manual records. Existing digital immunisation apps generally assume reliable internet connectivity, which is not available in these rural, hilly areas, and are not localised into Nepali or low-literacy users.

Proposed System

Overview

An offline mobile health (mHealth) application that helps mothers and caregivers track their children’s immunisation schedules and receive timely reminders. The application is usable by people with low or no health and/or technology literacy, meets WCAG/W3C accessibility guidelines, and is available in both English and Nepali language.

Functional Requirements

Child Registration

The system should allow a caregiver to create and manage profiles for multiple children within a household, capturing child name/ID, date of birth, sex, parent/caregiver name, parent/caregiver phone number, location (province, district, local level/municipality, ward number, address), and language preference.

The system should automatically calculate the child’s age and their vaccine due dates from date of birth, according to official Nepal National Immunisation Programme (NIP).

Schedule, Status Tracking, and Catch-Up

The system should display each child’s immunisation schedule with a clear and colour-independent status per vaccine (Completed, Upcoming, or Overdue).

The system should apply a catch-up scheduling logic for missed doses per vaccine (e.g. missed dose intervals and age cut-offs), according with the NIP schedule.

Reminders & Notifications

The system should send an advance reminder one week before a vaccine’s due date, a preparation reminder one day before, and a same-day reminder, via the device’s native calendar/notification system, without needing an internet connection.

If a vaccination is missed, the system should continue sending follow-up reminders (i.e. one day and one week after the missed date), mark the vaccination Overdue after one week, then send periodic (e.g. fortnightly) reminders rather than daily alerts, to avoid reminder fatigue.

Vaccine Record Management

The system should allow a caregiver or health workers to mark a scheduled vaccination as completed, recording the vaccination date and vaccination centre, with an optional photo of the vaccination card.

The system should let a caregiver view their child’s complete immunisation history.

The system should provide a health worker mode that allows search for a child’s record, update vaccination records, and verify missed vaccines.

Caregiver Education

The system should provide an immunisation education section (why vaccines matter, common side effects, and a myth-and-fact section), adapted from Nepal’s Family Welfare Division IEC materials.

Health Facility Locater

The system should let a caregiver search for a nearby vaccination services (health posts, primary health care centres, district hospitals, immunisation outreach clinics) from an offline-saved facility list, with contact details if available, and map-based navigation when an internet connection is stable.

Language, Accessibility, and Offline Behaviour

The system should allow the user to switch the display language between English and Nepali at any time, loading text from separate JSON translation files, and should use simple terminology (e.g. Health Post = स्वास्थ्य चौकी).

The system should offer an optional voice/audio reading of key on-screen text, to support caregivers with low or no literacy.

The system should encrypt sensitive data (children’s birth dates, vaccination records, location, parent contact details) and support device-native biometric or PIN protection.

The system should store child profiles, the vaccine schedule, and reminders locally while retaining full core functionality without an internet connection. Additionally, the system should opportunistically sync stored data without blocking offline use when a connection becomes available.

The system should present all core screens using large icons, simple navigation, and minimal text, appropriate for low/zero-literacy users.

Nonfunctional Requirements

User Interface and Human Factors

The primary users are mothers/caregivers with low or no health/technology literacy. The interface must be learnable without formal training, favour icons/imagery over text, and meet the WCAG/W3C guidelines for contrast, font size, and language complexity. Error-prevention (e.g. a confirmation screen before deleting a profile) matters more than efficiency features aimed at expert users.

Documentation

Our team will produce a short in-app onboarding flow for caregivers, a README guide in the client’s GitHub repository for developers, while adding a brief handover document summarising design decisions and known limitations for the client group.

Hardware Consideration

The app must run on basic, inexpensive Android and iOS smartphones that are already in use in the target communities. This includes having limited RAM, storage, and older OS versions.

Performance Characteristics

The app should launch and respond within a few seconds on low-spec devices. As there is no network dependency for core functionality, performance is focused mainly on-device storage and processing.

Error Handling and Extreme Conditions

The system should handle invalid/missing date of birth (DOB) input, low device storage, device clock changes affecting scheduled reminders, and failed biometric authentication.

System Interfacing

The app is offline-first: all core functionality (profile, schedule, reminders, records, education content, saved facility list) works with no network connection. When a connection becomes available, the app should opportunistically sync stored data in background. Other interfaces are internal, such as the device's native calendar/notification APIs (reminders), the device's secure storage/biometric API (encryption), and local JSON files (for translations and immunisation schedule content supplied by the client). Map-based navigation for the Health Facility Locator additionally requires connectivity when used.

Quality Issues

Reliability matters more than feature count: data must not be lost across app updates, restarts or crashes, since users only have one device and no cloud backup. Additionally, code quality is maintained through mandatory human review of any AI-assisted code. Portability across a range of Android and iOS versions is required given device fragmentation in the target communities.

System Modifications (x)

[not sure here what parts of the system are likely candidates for later modification?]

Physical Environment

The target environment is rural, hilly Nepal, with inconsistent access to electricity for charging and variable network coverage. The app should remain usable outdoors in bright sunlight (sufficient contrast) and be light on battery use (e.g. efficient reminder scheduling rather than constant background polling).

Security Issues

Access should be protected using the device’s existing biometric or PIN security, with data encrypted at rest using established libraries rather than custom cryptography. Since the app does not transmit data externally, the main risks are device loss/theft and shared device within a household. Both issue can be mitigated using local authentication.

Resource Issues

Opportunistic sync provides a partial backup when connectivity is available, but this cannot be relied on in areas with rare connectivity, hence a simple local export/import feature should still be considered as a fallback. Moreover, the GitHub repository is maintained under the client's organisation. Optional vaccination-card photo uploads should be compressed/limited in size given constrained on-device storage.

Constraints

All output must be released under a Creative Commons (open-source) license, as stated per the client’s IP terms.

The app’s core functionality (profile, schedule, reminders, records, education, saved facility list) must work fully offline. Connectivity may only be used opportunistically (e.g. background sync, live map navigation), never required.

Version control and issue tracking must be hosted under the client’s official GitHub repository.

AI-assisted coding is permitted only with mandatory human review of generated code.

Development time is constrained by CITS3200 being one of the four current units per team member.

Choice of mobile framework/libraries is otherwise left to our team, subject to offline-storage and encryption support.

Reminder wording and catch-up scheduling rules must follow the specific text and clinical intervals supplied by the client.

System Model

Scenarios

Scenario A: Maya, a mother in a hilly village with no reliable network coverage, opens the app after her daughter’s birth and creates a profile for her. The app immediately shows the upcoming vaccination schedule, entirely offline. Two months later, a native reminder notifies Maya the day before her daughter’s next vaccination is due, in Nepali language.

Scenario B: A community health worker is visiting several households and uses the app to mark vaccinations as completed immediately after administering them. The worker taps through a simple icon-based flow without needing to read or write detailed notes.

Use Case Models

Actors

Primary actors: mother/caregiver

Secondary actors: health workers

Use Cases

Object Models

Data Dictionary (key entities):

Class Diagram:

Dynamic Models

To be added after reminder-scheduling and language-switching flows are finalised.

User Interface – Navigational Paths and Screen Mockups

To be added with team’s final Figma prototypes.

| Child | Type | Description |

|---|---|---|

| id | UUID | Unique identifier for the child profile |

| name | String | Child’s name |

| dateOfBirth | Date | Used to calculate the immunisation schedule |



| VaccinationRecord | Type | Description |

|---|---|---|

| vaccineName | String | Name of the scheduled vaccine |

| dueDate | Date | Date of the vaccination is due |

| completedDate | Date (nullable) | Date of the vaccination was administered (if completed) |

| status | Enum | Upcoming/Due/Overdue/Completed |



| Reminder | Type | Description |

|---|---|---|

| triggerDate | DateTime | When the native notification/calendar entry fires |

| message | String | Localised reminder text (English/Nepali) |

