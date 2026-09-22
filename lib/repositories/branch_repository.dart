import '../models/branch_model.dart';
import '../services/firestore_service.dart';

class BranchRepository {
  final FirestoreService _firestoreService;

  BranchRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<BranchModel>> streamBranches() => _firestoreService.streamBranches();

  Future<List<BranchModel>> getBranches() => _firestoreService.getBranches();

  Future<void> saveBranch(BranchModel branch) => _firestoreService.saveBranch(branch);

  Future<void> deleteBranch(String branchId) => _firestoreService.deleteBranch(branchId);
}
