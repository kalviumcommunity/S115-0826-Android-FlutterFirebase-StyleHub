// Booking request data transfer model before final confirmation
class BookingModel {
  final String? branchId;
  final String? branchName;
  final String? serviceId;
  final String? serviceName;
  final double? servicePrice;
  final int? serviceDuration;
  final String? stylistId;
  final String? stylistName;
  final String? appointmentDate; // YYYY-MM-DD
  final String? startTime; // "11:00 AM"
  final String? notes;

  const BookingModel({
    this.branchId,
    this.branchName,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.serviceDuration,
    this.stylistId,
    this.stylistName,
    this.appointmentDate,
    this.startTime,
    this.notes,
  });

  bool get isBranchSelected => branchId != null && branchId!.isNotEmpty;
  bool get isServiceSelected => serviceId != null && serviceId!.isNotEmpty;
  bool get isStylistSelected => stylistId != null && stylistId!.isNotEmpty;
  bool get isDateTimeSelected => appointmentDate != null && startTime != null;
  bool get isComplete => isBranchSelected && isServiceSelected && isStylistSelected && isDateTimeSelected;

  BookingModel copyWith({
    String? branchId,
    String? branchName,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    int? serviceDuration,
    String? stylistId,
    String? stylistName,
    String? appointmentDate,
    String? startTime,
    String? notes,
  }) {
    return BookingModel(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      notes: notes ?? this.notes,
    );
  }
}
