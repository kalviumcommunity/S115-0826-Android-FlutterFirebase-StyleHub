import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../models/appointment_model.dart';
import '../models/appointment_slot_model.dart';

class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Streams
  Stream<List<BranchModel>> getBranches() {
    return _db.collection('branches').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BranchModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ServiceModel>> getServices() {
    return _db.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<StylistModel>> getStylists() {
    return _db.collection('stylists').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StylistModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<AppointmentModel>> getCustomerAppointments(String customerId) {
    return _db
        .collection('appointments')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Stream<List<AppointmentModel>> getBranchAppointments(String branchId) {
    return _db
        .collection('appointments')
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Stream<List<AppointmentModel>> getAllAppointments() {
    return _db.collection('appointments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // Double-booking protected transaction
  Future<AppointmentModel> bookAppointment({
    required String appointmentId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String branchId,
    required String branchName,
    required String stylistId,
    required String stylistName,
    required String serviceId,
    required String serviceName,
    required double servicePrice,
    required String appointmentDate,
    required String startTime,
    required String endTime,
    String notes = '',
  }) async {
    final slotId = 'slot_${branchId}_${stylistId}_${appointmentDate}_${startTime.replaceAll(RegExp(r'\\s+'), '')}';

    final appointment = AppointmentModel(
      appointmentId: appointmentId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      branchId: branchId,
      branchName: branchName,
      stylistId: stylistId,
      stylistName: stylistName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      status: 'Confirmed',
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final slot = AppointmentSlotModel(
      slotId: slotId,
      branchId: branchId,
      stylistId: stylistId,
      appointmentDate: appointmentDate,
      startTime: startTime,
      appointmentId: appointmentId,
      customerId: customerId,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _db.runTransaction((transaction) async {
      final slotRef = _db.collection('appointmentSlots').doc(slotId);
      final aptRef = _db.collection('appointments').doc(appointmentId);

      final slotSnapshot = await transaction.get(slotRef);
      if (slotSnapshot.exists) {
        throw Exception('The selected slot $startTime is already booked. Please choose another time.');
      }

      transaction.set(slotRef, slot.toMap());
      transaction.set(aptRef, appointment.toMap());
    });

    return appointment;
  }

  Future<void> cancelAppointment(AppointmentModel appointment, {String reason = 'Cancelled by user'}) async {
    final slotId = 'slot_${appointment.branchId}_${appointment.stylistId}_${appointment.appointmentDate}_${appointment.startTime.replaceAll(RegExp(r'\\s+'), '')}';

    await _db.runTransaction((transaction) async {
      final slotRef = _db.collection('appointmentSlots').doc(slotId);
      final aptRef = _db.collection('appointments').doc(appointment.appointmentId);

      final aptDoc = await transaction.get(aptRef);
      if (!aptDoc.exists) {
        throw Exception('Appointment not found.');
      }

      transaction.update(aptRef, {
        'status': 'Cancelled',
        'notes': 'Cancelled: $reason',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      transaction.delete(slotRef);
    });
  }

  Future<void> rescheduleAppointment({
    required AppointmentModel appointment,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    final oldSlotId = 'slot_${appointment.branchId}_${appointment.stylistId}_${appointment.appointmentDate}_${appointment.startTime.replaceAll(RegExp(r'\\s+'), '')}';
    final newSlotId = 'slot_${appointment.branchId}_${appointment.stylistId}_${newDate}_${newStartTime.replaceAll(RegExp(r'\\s+'), '')}';

    await _db.runTransaction((transaction) async {
      final aptRef = _db.collection('appointments').doc(appointment.appointmentId);
      final oldSlotRef = _db.collection('appointmentSlots').doc(oldSlotId);
      final newSlotRef = _db.collection('appointmentSlots').doc(newSlotId);

      final newSlotDoc = await transaction.get(newSlotRef);
      if (newSlotDoc.exists) {
        throw Exception('The selected slot $newStartTime is already booked. Please choose another time.');
      }

      final newSlot = AppointmentSlotModel(
        slotId: newSlotId,
        branchId: appointment.branchId,
        stylistId: appointment.stylistId,
        appointmentDate: newDate,
        startTime: newStartTime,
        appointmentId: appointment.appointmentId,
        customerId: appointment.customerId,
        createdAt: DateTime.now().toIso8601String(),
      );

      transaction.set(newSlotRef, newSlot.toMap());
      transaction.delete(oldSlotRef);

      transaction.update(aptRef, {
        'appointmentDate': newDate,
        'startTime': newStartTime,
        'endTime': newEndTime,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status, {String? notes}) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (notes != null) {
      data['notes'] = notes;
    }
    await _db.collection('appointments').doc(appointmentId).update(data);
  }

  Future<void> seedDatabaseIfEmpty() async {
    final branchesSnap = await _db.collection('branches').limit(1).get();
    if (branchesSnap.docs.isNotEmpty) return; // Already seeded

    final batch = _db.batch();

    // 1. Seed Branches
    final branchIds = ['branch_downtown', 'branch_2', 'branch_3'];
    final branches = [
      BranchModel(
        branchId: branchIds[0],
        name: 'The Luxe Studio - Downtown',
        address: '123 Elite Avenue',
        city: 'Downtown City',
        phone: '555-0101',
        openingHours: '09:00 AM - 08:00 PM',
        description: 'Premium salon in the heart of the city.',
        image: 'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?w=800&q=80',
        active: true,
      ),
      BranchModel(
        branchId: branchIds[1],
        name: 'Westside Premium Barbers',
        address: '450 West End Drive',
        city: 'Westside',
        phone: '555-0202',
        openingHours: '09:00 AM - 08:00 PM',
        description: 'Classic grooming and styling.',
        image: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800&q=80',
        active: true,
      ),
      BranchModel(
        branchId: branchIds[2],
        name: 'Oasis Spa & Salon',
        address: '789 Serenity Lane',
        city: 'Oasis',
        phone: '555-0303',
        openingHours: '09:00 AM - 08:00 PM',
        description: 'Relaxing spa treatments and hair care.',
        image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&q=80',
        active: true,
      ),
    ];

    for (var branch in branches) {
      batch.set(_db.collection('branches').doc(branch.branchId), branch.toMap());
    }

    // 2. Seed Services
    final serviceIds = ['srv_1', 'srv_2', 'srv_3', 'srv_4', 'srv_5', 'srv_6'];
    final services = [
      ServiceModel(serviceId: serviceIds[0], name: 'Signature Haircut', description: 'Premium haircut with hot towel.', price: 45.0, duration: 45, image: '', category: 'Hair', active: true),
      ServiceModel(serviceId: serviceIds[1], name: 'Executive Shave', description: 'Classic straight razor shave.', price: 35.0, duration: 30, image: '', category: 'Beard', active: true),
      ServiceModel(serviceId: serviceIds[2], name: 'Hair Coloring', description: 'Full or partial premium color.', price: 120.0, duration: 120, image: '', category: 'Color', active: true),
      ServiceModel(serviceId: serviceIds[3], name: 'Rejuvenating Facial', description: 'Deep cleansing and hydration.', price: 65.0, duration: 60, image: '', category: 'Skin', active: true),
      ServiceModel(serviceId: serviceIds[4], name: 'Beard Sculpting', description: 'Precision trim and line up.', price: 25.0, duration: 30, image: '', category: 'Beard', active: true),
      ServiceModel(serviceId: serviceIds[5], name: 'Scalp Massage', description: 'Relaxing 20-min massage.', price: 30.0, duration: 20, image: '', category: 'Relax', active: true),
    ];

    for (var srv in services) {
      batch.set(_db.collection('services').doc(srv.serviceId), srv.toMap());
    }

    // 3. Seed Stylists
    final stylists = [
      StylistModel(
        stylistId: 'sty_1',
        branchId: branchIds[0],
        name: 'Alex Rivera',
        bio: 'Master Barber',
        specialization: 'Fades',
        experience: '5+ years',
        rating: 4.9,
        profileImage: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&q=80',
        active: true,
      ),
      StylistModel(
        stylistId: 'sty_2',
        branchId: branchIds[0],
        name: 'Sophia Chen',
        bio: 'Color Specialist',
        specialization: 'Coloring',
        experience: '3+ years',
        rating: 4.8,
        profileImage: 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=800&q=80',
        active: true,
      ),
      StylistModel(
        stylistId: 'sty_3',
        branchId: branchIds[1],
        name: 'Marcus Bell',
        bio: 'Fades & Edges',
        specialization: 'Edging',
        experience: '7+ years',
        rating: 4.7,
        profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
        active: true,
      ),
      StylistModel(
        stylistId: 'sty_4',
        branchId: branchIds[2],
        name: 'Emma Watson',
        bio: 'Skin & Facials',
        specialization: 'Skin',
        experience: '4+ years',
        rating: 4.9,
        profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
        active: true,
      ),
      StylistModel(
        stylistId: 'sty_5',
        branchId: branchIds[2],
        name: 'David Kim',
        bio: 'Senior Stylist',
        specialization: 'Styling',
        experience: '10+ years',
        rating: 4.6,
        profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
        active: true,
      ),
    ];

    for (var sty in stylists) {
      batch.set(_db.collection('stylists').doc(sty.stylistId), sty.toMap());
    }

    await batch.commit();
  }
}
