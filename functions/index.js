const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createStaffAccount = functions.https.onCall(async (data, context) => {
  // 1. Authenticated?
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to create a staff account.");
  }

  const callerUid = context.auth.uid;

  // 2. Is caller admin? (Check their Firestore profile)
  const callerRef = admin.firestore().collection("users").doc(callerUid);
  const callerDoc = await callerRef.get();
  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Only administrators can create staff accounts.");
  }

  const { name, email, phone, gender, assignedBranchId, password } = data;

  // 3. Validate Inputs
  if (!name || !email || !phone || !gender || !assignedBranchId || !password) {
    throw new functions.https.HttpsError("invalid-argument", "All fields are required.");
  }

  const validGenders = ["Male", "Female", "Other", "Prefer not to say"];
  if (!validGenders.includes(gender)) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid gender value.");
  }

  // 4. Validate Branch
  const branchRef = admin.firestore().collection("branches").doc(assignedBranchId);
  const branchDoc = await branchRef.get();
  if (!branchDoc.exists || (!branchDoc.data().active && !branchDoc.data().isActive)) {
    throw new functions.https.HttpsError("failed-precondition", "The assigned branch does not exist or is deactivated.");
  }

  // 4b. Enforce one active staff per branch
  const staffSnapshot = await admin.firestore().collection("users")
    .where("role", "==", "staff")
    .where("assignedBranchId", "==", assignedBranchId)
    .get();
  
  const hasActiveStaff = staffSnapshot.docs.some(doc => doc.data().isActive === true || doc.data().active === true);
  if (hasActiveStaff) {
    throw new functions.https.HttpsError("failed-precondition", "This branch already has an active Staff member. Only one active staff is allowed per branch.");
  }

  // 5. Create Auth Account
  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });
  } catch (error) {
    throw new functions.https.HttpsError("already-exists", `Failed to create auth account: ${error.message}`);
  }

  // 6. Create Firestore Profile
  try {
    const now = admin.firestore.FieldValue.serverTimestamp();
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      gender: gender,
      role: "staff",
      assignedBranchId: assignedBranchId,
      branchId: assignedBranchId, // Storing in both just for legacy fallback compatibility
      isActive: true,
      mustChangePassword: true,
      createdAt: now,
      updatedAt: now,
    });
  } catch (error) {
    // 7. Failure Safety - Handle partial failure (Auth created, but Firestore failed)
    await admin.auth().deleteUser(userRecord.uid);
    throw new functions.https.HttpsError("internal", `Failed to create Firestore profile. Orphan auth account deleted. Error: ${error.message}`);
  }

  return { success: true, uid: userRecord.uid, message: "Staff account created successfully." };
});
