import 'package:flutter/foundation.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../models/appointment_model.dart';
import '../repositories/firestore_repository.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreRepository _repository = FirestoreRepository();

  List<BranchModel> branches = [];
  List<ServiceModel> services = [];
  List<StylistModel> stylists = [];
  List<AppointmentModel> customerAppointments = [];
  List<AppointmentModel> branchAppointments = [];

  DataProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _repository.seedDatabaseIfEmpty();
    } catch (e) {
      debugPrint('Seeding failed: $e');
    }

    _repository.getBranches().listen((data) {
      branches = data;
      notifyListeners();
    });

    _repository.getServices().listen((data) {
      services = data;
      notifyListeners();
    });

    _repository.getStylists().listen((data) {
      stylists = data;
      notifyListeners();
    });
  }

  void loadCustomerAppointments(String customerId) {
    _repository.getCustomerAppointments(customerId).listen((data) {
      customerAppointments = data;
      notifyListeners();
    });
  }

  void loadBranchAppointments(String branchId) {
    _repository.getBranchAppointments(branchId).listen((data) {
      branchAppointments = data;
      notifyListeners();
    });
  }

  Future<void> cancelAppointment(AppointmentModel appointment) async {
    await _repository.cancelAppointment(appointment);
  }
}
