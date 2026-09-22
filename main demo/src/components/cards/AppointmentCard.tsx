import React from 'react';
import { Calendar, Clock, MapPin, Scissors, XCircle, RotateCcw, AlertTriangle } from 'lucide-react';
import { Appointment } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { StatusBadge } from '../common/FeedbackWidgets';

interface AppointmentCardProps {
  appointment: Appointment;
  onCancel?: (appointmentId: string) => void;
  onRebook?: (appointment: Appointment) => void;
  showCustomerInfo?: boolean;
}

export const AppointmentCard: React.FC<AppointmentCardProps> = ({
  appointment,
  onCancel,
  onRebook,
  showCustomerInfo = false,
}) => {
  const isUpcoming = appointment.status === 'Pending' || appointment.status === 'Confirmed';
  const isCompleted = appointment.status === 'Completed';

  return (
    <AppCard padding="none" className="overflow-hidden border border-slate-100 shadow-xs">
      {/* Header bar */}
      <div className="bg-slate-50/80 px-4 py-2.5 border-b border-slate-100 flex items-center justify-between">
        <div className="flex items-center gap-1.5 text-xs font-semibold text-slate-700">
          <MapPin className="w-3.5 h-3.5 text-rose-500 shrink-0" />
          <span className="truncate">{appointment.branchName}</span>
        </div>
        <StatusBadge status={appointment.status} size="sm" />
      </div>

      <div className="p-4 space-y-3">
        {/* Service & Price */}
        <div className="flex items-start justify-between gap-2">
          <div>
            <h4 className="text-sm font-bold text-slate-900">{appointment.serviceName}</h4>
            <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
              <Scissors className="w-3 h-3 text-slate-400 shrink-0" />
              Stylist: <span className="font-medium text-slate-700">{appointment.stylistName}</span>
            </p>
          </div>
          <span className="text-sm font-bold text-slate-900 shrink-0">
            ₹{appointment.servicePrice}
          </span>
        </div>

        {/* Customer details for staff/admin views */}
        {showCustomerInfo && (
          <div className="p-2.5 rounded-xl bg-slate-50 border border-slate-100 text-xs space-y-1">
            <div className="flex justify-between text-slate-700">
              <span className="text-slate-400">Customer:</span>
              <span className="font-semibold">{appointment.customerName}</span>
            </div>
            <div className="flex justify-between text-slate-500 text-[11px]">
              <span>ID: {appointment.customerId}</span>
              <span>{appointment.customerPhone}</span>
            </div>
          </div>
        )}

        {/* Timing info */}
        <div className="flex items-center justify-between text-xs text-slate-600 pt-1">
          <div className="flex items-center gap-1.5 bg-slate-100/70 px-2.5 py-1 rounded-lg">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-medium">{appointment.appointmentDate}</span>
          </div>
          <div className="flex items-center gap-1.5 bg-slate-100/70 px-2.5 py-1 rounded-lg">
            <Clock className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-medium">{appointment.startTime} - {appointment.endTime}</span>
          </div>
        </div>

        {appointment.notes && (
          <p className="text-[11px] text-slate-500 italic bg-amber-50/50 p-2 rounded-lg border border-amber-100/60">
            Note: {appointment.notes}
          </p>
        )}

        {/* Action buttons */}
        <div className="pt-2 border-t border-slate-100 flex items-center justify-between gap-2">
          <span className="text-[11px] text-slate-400">
            ID: #{appointment.appointmentId.slice(-6)}
          </span>

          <div className="flex items-center gap-2">
            {isUpcoming && onCancel && (
              <AppButton
                variant="danger"
                size="sm"
                leftIcon={<XCircle className="w-3.5 h-3.5" />}
                onClick={() => onCancel(appointment.appointmentId)}
              >
                Cancel
              </AppButton>
            )}

            {isCompleted && onRebook && (
              <AppButton
                variant="outline"
                size="sm"
                leftIcon={<RotateCcw className="w-3.5 h-3.5" />}
                onClick={() => onRebook(appointment)}
              >
                Book Again
              </AppButton>
            )}
          </div>
        </div>
      </div>
    </AppCard>
  );
};
