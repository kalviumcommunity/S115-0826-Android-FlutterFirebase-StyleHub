class AppointmentSlotModel {
  final String slotId;
  final String branchId;
  final String stylistId;
  final String appointmentDate;
  final String startTime;
  final String appointmentId;
  final String customerId;
  final String createdAt;

  AppointmentSlotModel({
    required this.slotId,
    required this.branchId,
    required this.stylistId,
    required this.appointmentDate,
    required this.startTime,
    required this.appointmentId,
    required this.customerId,
    required this.createdAt,
  });

  factory AppointmentSlotModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentSlotModel(
      slotId: id,
      branchId: data['branchId'] ?? '',
      stylistId: data['stylistId'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      startTime: data['startTime'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      customerId: data['customerId'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slotId': slotId,
      'branchId': branchId,
      'stylistId': stylistId,
      'appointmentDate': appointmentDate,
      'startTime': startTime,
      'appointmentId': appointmentId,
      'customerId': customerId,
      'createdAt': createdAt,
    };
  }
}
