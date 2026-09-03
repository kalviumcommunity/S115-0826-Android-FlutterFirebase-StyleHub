# Firestore Database Structure Review: Multi-Branch Single-Project Architecture

**Author:** Ayush Awchar (Backend / Security)  
**Date:** September 2026  
**Context:** StyleHub Multi-Branch Salon Platform  

---

## 1. Overview & Architectural Strategy

StyleHub operates across multiple physical salon branches with the core product philosophy: **"One customer identity, every branch."**

To balance seamless cross-branch customer experiences with strict branch operational boundaries, the application implements a **Single-Project, Multi-Branch NoSQL Architecture** in Cloud Firestore rather than an isolated multi-project / multi-database silo model.

```
Firestore Database Instance (stylehub-default)
├── users/{uid}                     --> Global customer/staff identity (FR-02)
├── branches/{branchId}             --> Branch metadata & config
├── stylists/{stylistId}            --> Stylists scoped via `branchId`
├── services/{serviceId}            --> Service catalogue scoped via `branchId`
├── appointments/{appointmentId}    --> Bookings scoped via `branchId` & `customerId`
├── appointmentSlots/{slotId}       --> Deterministic concurrency locking ({stylistId}_{yyyyMMdd}_{HHmm})
└── serviceHistory/{historyId}      --> Cross-branch completed service audit trail
```

---

## 2. Multi-Tenancy Risk Assessment & Mitigations

Unstructured multi-tenancy can introduce severe data privacy, access leakage, and configuration risks. Below is an analysis of each risk vector and its mitigation in StyleHub:

### Risk 1: Cross-Tenant Data Leakage & Unauthorized Mutation
* **Threat:** Staff at Branch A reading/mutating appointments, service records, or stylists belonging to Branch B.
* **Mitigation:**
  * **Role-Based Token Claims:** Staff custom claims (`request.auth.token.branchId` and `request.auth.token.role == 'staff'`) strictly scope all write operations.
  * **Security Rules Guardrails:**
    ```javascript
    function isStaff(branchId) {
      return isAuthenticated() && 
             request.auth.token.role == 'staff' && 
             request.auth.token.branchId == branchId;
    }
    ```
  * Mutations on branch-specific collections (`appointments`, `stylists`, `services`, `serviceHistory`) enforce `isStaff(resource.data.branchId)` or `isStaff(request.resource.data.branchId)`.

### Risk 2: Cross-Branch Identity Fragmentation (The "Silo Problem")
* **Threat:** Duplicated customer profiles when visiting multiple branches, causing loss of visit history and stylist preferences.
* **Mitigation:**
  * Customer accounts are keyed to the single **Firebase Auth UID** at `users/{uid}`.
  * Customer profiles are not scoped to any single branch.
  * Cross-branch service history queries (`serviceHistory.where('customerId', '==', uid)`) aggregate visits across all branches without requiring cross-database federation.

### Risk 3: Privilege Escalation on Global Identity
* **Threat:** A customer modifying their document in `users/{uid}` to elevate their role to `staff` or `admin`.
* **Mitigation:**
  * User profile creation locks the initial role strictly to `'customer'`.
  * User profile update rules prohibit changes to the `role` field unless executed by an admin:
    ```javascript
    allow update: if (isOwner(uid) && request.resource.data.role == resource.data.role) || isAdmin();
    ```

### Risk 4: Double-Booking & Slot Concurrency Conflicts Across Branches
* **Threat:** Race conditions when booking a stylist or slot collisions across branches.
* **Mitigation:**
  * Deterministic slot keys: `{stylistId}_{yyyyMMdd}_{HHmm}` in `appointmentSlots/{slotId}`.
  * Executed within a strict Firestore Transaction (`AppointmentService.bookAppointment`).
  * Immutable slot documents: creation is transactional, updates are disallowed (`allow update: if false;`).

### Risk 5: Unscoped / Accidental Collection Access
* **Threat:** New collections introduced into Firestore without matching rules defaulting to open access.
* **Mitigation:**
  * Global default deny-all rule attached to the root database:
    ```javascript
    match /{document=**} {
      allow read, write: if false;
    }
    ```

---

## 3. Query Optimization & Indexing Strategy

To prevent costly table scans across multi-branch collections, the baseline schema defines composite indexes:
1. `serviceHistory`: `customerId` (ASC) + `completedAt` (DESC) — powers the customer visit history and "Returning Customer" recognition panel.
2. `appointments`: `customerId` (ASC) + `status` (ASC) + `scheduledAt` (ASC) — powers customer dashboard.
3. `appointments`: `branchId` (ASC) + `scheduledAt` (ASC) — powers the branch staff schedule.

---

## 4. Conclusion

The single-project, multi-branch Firestore structure achieves both goals:
1. **Zero Data Fragmentation:** Retains a unified network identity for every customer across all branches.
2. **Strict Operational Isolation:** Guarantees that branch staff cannot mutate records outside their designated `branchId`.
