import '../core/constants.dart';
import '../models/branch_model.dart';
import '../models/stylist_model.dart';
import '../services/firestore_service.dart';

/// Utility class that populates the Firestore `branches` and `stylists`
/// collections with realistic mock data so the frontend team is unblocked
/// for UI integration.
///
/// Design decisions:
/// - Uses deterministic document IDs (e.g., `branch_pune_koregaon_park`)
///   instead of auto-generated IDs. This makes cross-referencing predictable
///   and avoids duplicate seeds on re-runs.
/// - Data uses [BranchModel.toMap()] and [StylistModel.toMap()] to guarantee
///   the mock documents match the exact schema the app expects.
/// - Each stylist's [branchId] references a seeded branch, so the relational
///   integrity required by security rules and queries is maintained.
///
/// Usage:
/// ```dart
/// await MockDataSeeder(firestoreService: firestoreService).seed();
/// ```
class MockDataSeeder {
  final FirestoreService _firestoreService;

  MockDataSeeder({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Seeds all mock data. Safe to run multiple times — uses set() which
  /// overwrites existing documents with the same ID.
  Future<void> seed() async {
    await _seedBranches();
    await _seedStylists();
  }

  // ---------------------------------------------------------------------------
  // Branches
  // ---------------------------------------------------------------------------

  Future<void> _seedBranches() async {
    for (final branch in _branches) {
      await _firestoreService.setDocument(
        collection: FirestoreCollections.branches,
        documentId: branch.id,
        data: branch.toMap(),
      );
    }
  }

  static const _branches = [
    BranchModel(
      id: 'branch_pune_koregaon_park',
      name: 'StyleHub Koregaon Park',
      city: 'Pune',
      address: 'Lane 7, North Main Rd, Koregaon Park, Pune 411001',
      phone: '+91 20 2615 1234',
      imageUrl: null,
      openingHours: {
        'Monday': '09:00 - 21:00',
        'Tuesday': '09:00 - 21:00',
        'Wednesday': '09:00 - 21:00',
        'Thursday': '09:00 - 21:00',
        'Friday': '09:00 - 21:00',
        'Saturday': '10:00 - 22:00',
        'Sunday': '10:00 - 18:00',
      },
    ),
    BranchModel(
      id: 'branch_pune_hinjewadi',
      name: 'StyleHub Hinjewadi',
      city: 'Pune',
      address: 'Phase 1, Hinjewadi Rajiv Gandhi Infotech Park, Pune 411057',
      phone: '+91 20 2293 5678',
      imageUrl: null,
      openingHours: {
        'Monday': '10:00 - 20:00',
        'Tuesday': '10:00 - 20:00',
        'Wednesday': '10:00 - 20:00',
        'Thursday': '10:00 - 20:00',
        'Friday': '10:00 - 20:00',
        'Saturday': '10:00 - 21:00',
        'Sunday': 'Closed',
      },
    ),
    BranchModel(
      id: 'branch_mumbai_bandra',
      name: 'StyleHub Bandra West',
      city: 'Mumbai',
      address: '14th Rd, Khar West, Bandra, Mumbai 400052',
      phone: '+91 22 2600 9012',
      imageUrl: null,
      openingHours: {
        'Monday': '09:00 - 22:00',
        'Tuesday': '09:00 - 22:00',
        'Wednesday': '09:00 - 22:00',
        'Thursday': '09:00 - 22:00',
        'Friday': '09:00 - 22:00',
        'Saturday': '09:00 - 22:00',
        'Sunday': '10:00 - 20:00',
      },
    ),
  ];

  // ---------------------------------------------------------------------------
  // Stylists
  // ---------------------------------------------------------------------------

  Future<void> _seedStylists() async {
    for (final stylist in _stylists) {
      await _firestoreService.setDocument(
        collection: FirestoreCollections.stylists,
        documentId: stylist.id,
        data: stylist.toMap(),
      );
    }
  }

  static const _stylists = [
    // --- Koregaon Park Branch ---
    StylistModel(
      id: 'stylist_priya_sharma',
      name: 'Priya Sharma',
      branchId: 'branch_pune_koregaon_park',
      specialization: ['Hair Coloring', 'Bridal Makeup', 'Hair Spa'],
      photoUrl: null,
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    ),
    StylistModel(
      id: 'stylist_rahul_deshmukh',
      name: 'Rahul Deshmukh',
      branchId: 'branch_pune_koregaon_park',
      specialization: ['Haircuts', 'Beard Styling', 'Hair Straightening'],
      photoUrl: null,
      workingDays: ['Monday', 'Tuesday', 'Thursday', 'Friday', 'Saturday'],
    ),

    // --- Hinjewadi Branch ---
    StylistModel(
      id: 'stylist_anjali_patil',
      name: 'Anjali Patil',
      branchId: 'branch_pune_hinjewadi',
      specialization: ['Facials', 'Skin Care', 'Threading'],
      photoUrl: null,
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    ),
    StylistModel(
      id: 'stylist_vikram_joshi',
      name: 'Vikram Joshi',
      branchId: 'branch_pune_hinjewadi',
      specialization: ['Haircuts', 'Hair Coloring', 'Keratin Treatment'],
      photoUrl: null,
      workingDays: ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ),

    // --- Bandra West Branch ---
    StylistModel(
      id: 'stylist_neha_kapoor',
      name: 'Neha Kapoor',
      branchId: 'branch_mumbai_bandra',
      specialization: ['Bridal Makeup', 'Party Makeup', 'Hair Styling'],
      photoUrl: null,
      workingDays: ['Monday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ),
    StylistModel(
      id: 'stylist_arjun_mehta',
      name: 'Arjun Mehta',
      branchId: 'branch_mumbai_bandra',
      specialization: ['Haircuts', 'Beard Grooming', 'Scalp Treatment'],
      photoUrl: null,
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Saturday', 'Sunday'],
    ),
  ];
}
