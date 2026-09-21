import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      appointment.serviceName.isNotEmpty
                          ? appointment.serviceName
                          : 'Service',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              if (appointment.stylistName.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(appointment.stylistName,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              const SizedBox(height: 4),
              if (appointment.branchName.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.store_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(appointment.branchName,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy – hh:mm a')
                        .format(appointment.scheduledAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (appointment.price > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('₹${appointment.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'no_show':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}
