import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Layer: General-purpose Firestore CRUD wrapper.
///
/// This class, together with [AppointmentService], forms the Service Layer
/// for Firestore. No other layer imports `cloud_firestore` directly.
///
/// Design decisions:
/// - Generic methods that work with any collection — avoids a separate
///   service class per collection.
/// - Exposes stream-based methods for real-time UI updates (FR-18).
/// - Provides [runTransaction] and [writeBatch] pass-throughs for the
///   atomic operations mandated by TRD §3.
/// - Contains ZERO business logic — that responsibility belongs to Repositories.
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Single Document Operations
  // ---------------------------------------------------------------------------

  /// Creates or overwrites a document at `collection/documentId`.
  ///
  /// Uses `set` with merge:false (full overwrite) for predictable behavior.
  /// The calling Repository is responsible for building the complete data map.
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore
        .collection(collection)
        .doc(documentId)
        .set(data, SetOptions(merge: merge));
  }

  /// Reads a single document by ID. Returns null if it does not exist.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  /// Updates specific fields on an existing document.
  ///
  /// Throws if the document doesn't exist (unlike `set` with merge).
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  /// Deletes a document by ID.
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  // ---------------------------------------------------------------------------
  // Collection Queries
  // ---------------------------------------------------------------------------

  /// Queries a collection with optional where clauses, ordering, and limits.
  ///
  /// [queryBuilder] receives the base [CollectionReference] and should return
  /// a [Query] with the desired filters applied. This keeps filtering logic
  /// in the Repository layer while this layer handles the Firestore call.
  ///
  /// Example usage from a Repository:
  /// ```dart
  /// final result = await firestoreService.queryCollection(
  ///   collection: 'appointments',
  ///   queryBuilder: (ref) => ref
  ///     .where('customerId', isEqualTo: uid)
  ///     .orderBy('scheduledAt'),
  /// );
  /// ```
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(_firestore.collection(collection));
    }
    return await query.get();
  }

  // ---------------------------------------------------------------------------
  // Real-Time Streams (FR-18)
  // ---------------------------------------------------------------------------

  /// Streams a single document for real-time updates.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  /// Streams a collection query for real-time updates.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(_firestore.collection(collection));
    }
    return query.snapshots();
  }

  // ---------------------------------------------------------------------------
  // Atomic Operations (TRD §3)
  // ---------------------------------------------------------------------------

  /// Exposes Firestore transactions for operations that require
  /// read-then-write atomicity (e.g., double-booking prevention).
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async {
    return await _firestore.runTransaction(handler);
  }

  /// Creates a new [WriteBatch] for operations that require atomic
  /// multi-document writes (e.g., appointment completion).
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  /// Convenience: returns a [DocumentReference] for use in transactions/batches.
  DocumentReference<Map<String, dynamic>> docRef(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId);
  }

  /// Convenience: returns a [DocumentReference] with an auto-generated ID.
  DocumentReference<Map<String, dynamic>> autoIdDocRef(String collection) {
    return _firestore.collection(collection).doc();
  }
}
