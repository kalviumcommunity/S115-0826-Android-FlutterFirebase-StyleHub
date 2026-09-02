# STYLEHUB: One customer identity, every branch.
**Product Requirements Document - Version 1.0**
**Date:** August 2026
**Platform:** Flutter Mobile Application
**Backend:** Firebase (Authentication, Firestore, Cloud Storage)
**Team Members:** Ayush Awchar, Rishikesh Bagal, Sasmit Narnaware

---

## 1. Executive Summary
StyleHub is a centralized, multi-branch salon management application that solves a fragmented customer-identity problem across salon networks. StyleHub solves this by giving every customer a single network-wide identity—one Firebase Authentication UID—to which every appointment and service-history record across every branch is linked.

## 2. Problem Statement
### 2.1 The Existing Problem
* Customer records are duplicated across branches.
* Staff cannot easily see a customer's prior services.
* Stylist and service preferences are lost when a customer visits a different branch.
* Strategic decisions are made using branch-level data instead of network-wide data.

### 2.2 Root Cause
Each branch maintains its own customer identity instead of sharing one identity across the network.

### 2.3 Proposed Solution
One customer -> One Firebase Auth UID -> One profile -> All branch visits linked to that identity.

## 3. Product Vision
### 3.1 Product Goals
1. Establish one network-wide customer identity using the Firebase Authentication UID.
2. Allow customers to book appointments at any branch.
3. View complete appointment and service history across all branches.
4. Allow staff to search for any customer across the network.
5. Provide a "Returning Customer" recognition experience for staff.
6. Surface each customer's preferred stylist and most-booked service.
7. Provide real-time appointment status updates.
8. Prevent double-booking of a stylist's time slots.
9. Enforce role-based permissions using Firestore Security Rules.

### 3.2 Non-Goals V1
* Payment processing / gateway integration
* SMS / Push notification system
* Multi-currency / Multi-language support
* Staff payroll, attendance, and HR management
* Offline-first architecture

## 4. Target Users & Roles
| User | Description |
| :--- | :--- |
| **Customer** | Books appointments, visits branches, manages profile, views cross-branch history. |
| **Staff** | Works at a specific branch; manages customers, appointments, stylists, services. |
| **Admin** | Network-level manager; manages branches and has network-wide visibility. |

## 5. Core User Flows
### 5.1 Customer Flow
`Splash -> Auth Check -> Login/SignUp -> Home`
From Home:
* `Branches -> Branch Details -> Book Appointment -> Select Service -> Select Stylist -> Date/Time -> Confirm`
* `Appointments (Upcoming/Past)`
* `Service History (all branches)`
* `Profile (Edit/Photo/Logout)`

### 5.2 Staff / Admin Flow
`Login -> Dashboard`
* `Customers -> Search -> Customer Profile -> Returning Customer panel`
* `Appointments (Create/Update/Complete/Cancel)`
* `Management (Branches, Stylists, Services, Schedules)`

## 6. Functional Requirements
* **FR-01 Authentication:** Email/password registration/login. Persistent login.
* **FR-02 Centralized Customer Identity:** UID used as document ID at `users/{uid}`.
* **FR-08 Double-Booking Prevention:** Slot ID format `{stylistId}_{yyyyMMdd}_{HHmm}` used in a Firestore transaction.
* **FR-10 Service History Generation:** Batch write updates appointment to 'completed' and creates a `serviceHistory` document.
* **FR-11 Cross-Branch Customer Recognition:** Staff search surfaces Returning Customer panel.
* **FR-12 & 13 Analytics:** Calculate preferred stylist and most-booked service via Dart logic from history.
* **FR-18 Real-Time Data:** Firestore snapshot listeners drive live UI updates.

## 7. Screens & Navigation
| Screen | Purpose |
| :--- | :--- |
| **Splash / Login / Home** | Auth state, Authentication, Main dashboard |
| **Branches / Stylists / Services** | Browse, filter, and view details |
| **Book Appointment** | Guided appointment booking flow |
| **Staff Dashboard** | Staff operational overview |
| **Management Screens** | Admin & staff CRUD screens (Appointments, Branches, etc.) |

## 8. Data Model
| Collection | Key Fields |
| :--- | :--- |
| `users/{uid}` | uid, name, email, phone, role, branchId, profileImageUrl |
| `branches/{branchId}` | name, city, address, phone, imageUrl, openingHours |
| `stylists/{stylistId}` | name, branchId, specialization[], photoUrl, workingDays[] |
| `services/{serviceId}` | name, category, price, durationMinutes, branchId |
| `appointments/{id}` | customerId, branchId, stylistId, serviceId, scheduledAt, status |
| `appointmentSlots/{id}`| slotId, stylistId, scheduledAt, appointmentId |
| `serviceHistory/{id}` | customerId, appointmentId, branchId, stylistId, serviceId, completedAt |

## 9. Technical Architecture
* **Layered Architecture:** UI -> Providers (State) -> Repositories (Logic) -> Firebase Services
* **Tech Stack:** Flutter, Firebase Auth, Cloud Firestore, Cloud Storage, Provider (State).

## 10. Security Requirements
Security is enforced with **Firestore Security Rules**. UI-level restrictions alone are never considered a security control.

## 11. UX Requirements
Required states for every data-driven screen: **Loading, Empty, Error, Success**.

## 12. Core Firestore Queries
* **Customer Service History:** `where('customerId', == uid).orderBy('completedAt', desc)`
* **Upcoming Appointments:** `where('customerId', == uid).where('status', in: ['pending', 'confirmed']).where('scheduledAt', >= now).orderBy('scheduledAt')`
*(Note: Requires Composite Indexes)*