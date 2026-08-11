# Childhood Immunisation App: Nepal

# Objective

Develop a caregiver-friendly childhood immunisation tracking app aligned with Nepal’s National Immunization Programme (NIP). The app should automatically generate vaccine schedules, provide reminders, identify missed vaccines, support catch-up vaccination, and improve access to immunisation services, especially for rural and low-connectivity settings.

# 1. Child Registration

Purpose

Create a child profile that allows the system to automatically calculate vaccine eligibility and generate personalised reminders.

Data to Collect

Child Information

Child name or unique child ID

Date of birth

Sex

Parent/caregiver name

Parent/caregiver phone number

Location Information

Province

District

Local level/municipality

Ward number

Address

Language Preference

Nepali

Local language option (where available)

Automated Functions

The system should automatically calculate:

Child age (weeks/months/years)

Vaccine due dates based on date of birth

Upcoming vaccines

Overdue vaccines

Catch-up vaccination recommendations

# 2. Immunisation Schedule Tracker

Nepal National Immunization Programme (NIP) (1, 2)

The app should include the following vaccine schedule:

# 3. Vaccine Status Tracking System

Each vaccine should display a clear status indicator:

✓ Completed

○ Upcoming

⚠ Overdue

Example:

Child age: 10 weeks

✓ BCG — Completed
✓ Pentavalent dose 1 — Completed
⚠ Rotavirus dose 2 — Overdue
○ MR dose 1 — Upcoming

# 4. Missed-Dose Catch-Up Algorithm

The system should include automatic catch-up logic.

BCG

Can be given any time up to 5 years of age

No tuberculin test required before vaccination

Rotavirus

Two doses

Minimum interval: 1 month

Do not administer after 2 years of age

bOPV

Three doses if missed during infancy

Minimum interval: 1 month between doses

fIPV

Two doses if missed

Minimum interval: 4 months

PCV

If child is:

<12 months:

Three doses

1-month interval

12–23 months:

Two doses

2-month interval

MR Vaccine

9–15 months

Dose 1 at first contact

Dose 2 at 15 months

Minimum interval: 1 month

15 months–5 years

Two doses

Minimum interval: 1 month

TCV

Single dose

Eligible from ≥15 months to 5 years if missed

# 5. Reminder and Notification System (3)

Push Notification Message

Use exact wording:

"Your child is due for [vaccine name] on [date]. Please visit your nearest health post or immunisation clinic."

Overdue Notification

Use exact wording:

"[Vaccine name] is overdue. Contact your nearest health facility for catch-up vaccination."

Recommended reminder schedule (3-touch approach):

One week before the due date

Send an advance reminder to help caregivers prepare.

Include:

Vaccine name

Due date

Location of the nearest immunisation service/outreach session (if available)

One day before the due date

Send a preparation reminder.

Reinforce:

Tomorrow is the scheduled vaccination day

Where and when to attend

On the due date (same day)

Send a final reminder.

Use clear and simple language:

“Today is your child’s vaccination day”

Provide facility/outreach session details

If a vaccination is missed:

Do not stop reminders after the due date.

Send follow-up reminders:

1 day after the missed date

1 week after the missed date

Each follow-up should include:

The missed vaccine name

The importance of completing the schedule

The updated catch-up guidance (where applicable)

After one week overdue:

Change the vaccine status to “Overdue” in the app dashboard.

Provide periodic reminders (e.g., every two weeks) rather than frequent daily alerts to avoid reminder fatigue.

# 6. Vaccine Record Module

Allow caregivers or health workers to:

Mark vaccine as completed

Enter vaccination date

Record vaccination centre

Upload vaccination card photo (optional)

View complete immunisation history

Health worker mode can include:

Child search

Update vaccination records

Verify missed vaccines

# 7. Immunisation Education Module

Purpose

Improve caregiver knowledge and address vaccine hesitancy.

Education content should be adapted from Nepal’s Family Welfare Division IEC materials rather than generic vaccine information.

Topics:

Why Vaccines Are Important

Protect children from serious diseases

Prevent disability and childhood deaths

Protect the wider community

Common Side Effects

Include locally appropriate information:

Mild fever

Pain/swelling at injection site

Temporary irritability

Myth and Fact Section

Examples:

Myth: Vaccines cause illness.
Fact: Vaccines safely train the immune system to fight diseases.

Myth: A healthy child does not need vaccines.
Fact: Vaccination prevents diseases before exposure occurs.

# 8. Health Facility Locator

Purpose

Help caregivers find nearby vaccination services.

Facility categories:

Health Post (स्वास्थ्य चौकी)

Primary Health Care Centre

District Hospital

Immunisation Outreach Clinic

Features:

Search by location

Map-based navigation (when internet available)

Offline saved facility list

Contact details where available

Nepal-Specific App Design Requirements

Language

Nepali interface

Local language support where feasible

Use simple terminology suitable for caregivers with varying literacy levels

Offline Functionality

Required for rural areas:

Store child profile offline

Display vaccine schedule offline

Save reminders locally

Sync data when internet becomes available

Low-Data Design

Minimal images/videos

Small app size

Efficient data synchronisation

User Interface Design

Design principles:

Large icons

Simple navigation

Colour-independent status indicators

Voice/audio support option for low-literacy users

Use local terminology:

Example:

Health Post = स्वास्थ्य चौकी

# 9. Core Development Components

The app should include:

Child profile database

Age-based vaccine scheduling algorithm

Catch-up vaccination decision engine

Reminder notification system

Vaccine record management system

Facility locator

Offline data storage and synchronisation

Nepali-language user interface

Caregiver education section

# 10. Current Childhood Immunisation mHealth Apps/Platforms in Low- and Middle-Income Countries.

# 11. References:

1.	Update PH. National Immunization Schedule, Nepal (Updated): Public Health Update 2024 [cited 2026 3 August]. Available from: https://publichealthupdate.com/national-immunization-schedule-nepal/.

2.	Services DoH. Annual Health Report 2081/82 Kathmandu, Nepal: Department of Health Services, Ministry of Health & Population; 2026 [cited 2026 3 August]. Available from: https://hmis.gov.np/media/74/eBook-Digital---Annual-Health-Report-2081-82.pdf.

3.	Oliver-Williams C, Brown E, Devereux S, Fairhead C, Holeman I. Using mobile phones to improve vaccination uptake in 21 low-and middle-income countries: systematic review. JMIR mHealth and uHealth. 2017;5(10):e148.

| Age | Vaccine | Dose/Route/Site | Disease Prevented |

|---|---|---|---|

| At birth | BCG | 0.05 ml, intradermal, upper right arm | Tuberculosis |

| 6, 10, 14 weeks | DPT-HepB-Hib (Pentavalent) — 3 doses | 0.5 ml, IM, left thigh | Diphtheria, pertussis, tetanus, hepatitis B, Hib (meningitis/pneumonia) |

| 6, 10, 14 weeks | bOPV — 3 doses | 2 drops, oral | Poliomyelitis |

| 14 weeks & 9 months | fIPV — 2 doses | 0.1 ml, intradermal, upper right arm | Poliomyelitis |

| 6 & 10 weeks | Rotavirus — 2 doses | Oral | Rotavirus diarrhoea |

| 6, 10 weeks & 9 months | PCV — 3 doses | 0.5 ml, IM, middle right thigh | Pneumococcal pneumonia and meningitis |

| 9 & 15 months | MR — 2 doses | 0.5 ml, subcutaneous, upper left arm | Measles and rubella |

| 15 months | TCV — 1 dose | 0.5 ml, IM, middle left thigh | Typhoid |

| 12 months | JE — 1 dose | 0.5 ml, subcutaneous, upper right thigh | Japanese encephalitis |

| Grade 6 girls / 10-year-old girls not attending school | HPV — 1 dose | 0.5 ml, IM, upper left arm | Cervical cancer prevention |



| App/Platform | Country | Type | Key Features |

|---|---|---|---|

| U-WIN (Universal Immunization WIN) | India | Government national immunisation registry and app | Name-based digital registry for children (up to 6 years) and pregnant women; self-registration or facility registration; QR-based digital vaccination certificates; available in multiple Indian languages; supports vaccination continuity for migrant families through access across facilities; linked with national digital health records; vaccinator module for frontline workers to digitally record doses. |

| eVIN (Electronic Vaccine Intelligence Network) | India | Government vaccine supply-chain system | Not caregiver-facing. Tracks vaccine stocks, cold-chain temperature, and logistics in real time to support vaccine availability and improve immunisation programme management. |

| Khushi Baby | India (Rajasthan) | NGO pilot: wearable device + mobile application | Uses an NFC-enabled pendant containing a child’s vaccination record; health workers scan the pendant to update records; provides automated voice-call reminders to caregivers before immunisation camps; dashboards support community health workers with coverage monitoring and planning. |

| RapidSMS | Rwanda | Government/NGO SMS-based health monitoring system | Tracks mothers and children up to two years of age; sends SMS reminders to caregivers and healthcare providers for scheduled follow-up visits; integrated into broader maternal and child health monitoring rather than functioning as a standalone vaccination app. |

| MomConnect | South Africa | Government USSD/SMS/WhatsApp platform | National maternal and child health messaging service; provides stage-based health information during pregnancy and after birth, including immunisation-related messages; designed for low-resource settings using basic phones through USSD and SMS. |

| VaxEPI | Bangladesh | Government national immunisation registry | Digital immunisation registration platform linked with the child’s Birth Registration Number (BRN); centralises immunisation records and enables access across health facilities instead of relying only on paper vaccination cards. |

| Sindh Sehat Analytics Platform (Zenysis) | Pakistan | Government/NGO data integration platform | Integrates immunisation data from multiple sources, including vaccinator records and digital registries; identifies zero-dose and under-immunised populations; supports microplanning by linking vaccinators and community mobilisation activities. Primarily a health-system tool rather than a caregiver-facing application. |

| Zindagi Mehfooz | Pakistan | Digital immunisation registry | Records individual vaccination events digitally as part of the Expanded Programme on Immunization (EPI); contributes data to broader immunisation monitoring and analytics systems. |

| PrimaKu / Tentang Anak | Indonesia | Consumer parenting applications | Caregiver-facing applications in Bahasa Indonesia combining vaccination tracking with child growth, nutrition, and development information; represent the consumer health app model rather than a government immunisation registry. |

