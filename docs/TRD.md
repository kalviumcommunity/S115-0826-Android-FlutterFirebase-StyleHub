# STYLEHUB: Technical Requirements Document (TRD)

## 1. System Architecture
StyleHub follows a strict Layered Architecture to enforce the separation of concerns and maintain a scalable Flutter codebase. 

* **UI Layer:** Purely presentational. Widgets listen to Providers and never communicate directly with Firebase.
* **Provider Layer (State Management):** Utilizes the `provider` package to manage application state (e.g., authentication state, in-progress booking data, selected filters).
* **Repository Layer:** Encapsulates core business rules, booking validations, and analytical calculations (e.g., preferred stylist Dart logic). 
* **Service Layer:** Interfaces directly with external APIs (`AuthService`, `FirestoreService`, `StorageService`).

## 2. Database Schema (Firestore)
The database uses a denormalized NoSQL structure to optimize for fast read operations on list views.

**Collection: `users`**
* `uid` (String) - Maps directly to Firebase Auth UID
* `role` (String) - "customer", "staff", or "admin"
* `phone` (String) - Used for cross-branch lookup
* `branchId` (String, nullable) - Assigned branch for staff

**Collection: `appointments`**
* `customerId` (String)
* `customerName` (String) - Denormalized for UI performance
* `branchId` (String)
* `stylistId` (String)
* `serviceId` (String)
* `status` (String) - "pending", "confirmed", "completed", "cancelled", "no_show"
* `scheduledAt` (Timestamp)

**Collection: `appointmentSlots`**
* `slotId` (String) - Deterministic format: `{stylistId}_{yyyyMMdd}_{HHmm}`
* `appointmentId` (String)

**Collection: `serviceHistory`**
* `customerId` (String)
* `appointmentId` (String)
* `branchId` (String)
* `stylistId` (String)
* `completedAt` (Timestamp)

## 3. Core Technical Constraints

**Double-Booking Prevention Engine**
All bookings must use a strict Firestore Transaction. 
1. Client generates the deterministic `slotId` (e.g., `stylist123_20260815_1430`).
2. Transaction checks `appointmentSlots/{slotId}`.
3. If document exists, abort and return a user-friendly error.
4. If missing, the transaction atomically writes the `appointmentSlots` document and the main `appointments` document.

**Atomic Appointment Completion**
Marking an appointment as "completed" must execute via a Firestore Batch Write to guarantee data integrity:
1. Update `appointments/{id}` status to `completed`.
2. Create new document in `serviceHistory`.

## 4. Required Composite Indexes
To support the application's real-time queries, the following composite indexes must be pre-configured in the Firebase console:
* `serviceHistory`: `customerId` (ASC) + `completedAt` (DESC)
* `appointments`: `customerId` (ASC) + `status` (ASC) + `scheduledAt` (ASC)
* `appointments`: `branchId` (ASC) + `scheduledAt` (ASC)

## 5. Security & Access Control
Access is enforced entirely via Firestore Security Rules. UI hiding is not sufficient.
* **Customers:** `request.auth.uid == resource.data.customerId`
* **Staff:** Can read all customers and cross-branch history. Can only mutate data where `resource.data.branchId == request.auth.token.branchId`.
* **Admin:** Full read/write access across all network collections.