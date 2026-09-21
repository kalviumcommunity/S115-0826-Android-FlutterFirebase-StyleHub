import React, { useState } from 'react';
import { Calendar, Clock, AlertTriangle, Plus, Scissors } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { dataService } from '../../services/dataService';
import { Appointment } from '../../types';
import { AppointmentCard } from '../cards/AppointmentCard';
import { AppButton } from '../common/AppButton';
import { EmptyStateWidget } from '../common/FeedbackWidgets';

interface CustomerAppointmentsScreenProps {
  onStartBooking: () => void;
  onRebook: (appointment: Appointment) => void;
}

export const CustomerAppointmentsScreen: React.FC<CustomerAppointmentsScreenProps> = ({
  onStartBooking,
  onRebook,
}) => {
  const { currentUser } = useAuth();
  const [activeSubTab, setActiveSubTab] = useState<'upcoming' | 'past'>('upcoming');
  const [cancellingId, setCancellingId] = useState<string | null>(null);
  const [cancelReason, setCancelReason] = useState<string>('');

  const appointments = currentUser ? dataService.getCustomerAppointments(currentUser.uid) : [];

  const upcomingAppointments = appointments.filter(
    a => a.status === 'Confirmed' || a.status === 'Pending'
  );

  const pastAppointments = appointments.filter(
    a => a.status === 'Completed' || a.status === 'Cancelled'
  );

  const handleConfirmCancel = () => {
    if (!cancellingId) return;
    try {
      dataService.cancelAppointment(cancellingId, cancelReason || 'Cancelled by customer');
      setCancellingId(null);
      setCancelReason('');
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="space-y-4 pb-6">
      
      {/* Screen Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900">My Appointments</h2>
          <p className="text-xs text-slate-500">Track and manage your upcoming & past salon visits</p>
        </div>
        <AppButton
          size="sm"
          variant="primary"
          onClick={onStartBooking}
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Book
        </AppButton>
      </div>

      {/* Tabs */}
      <div className="flex rounded-xl bg-slate-100 p-1 text-xs font-semibold">
        <button
          onClick={() => setActiveSubTab('upcoming')}
          className={`flex-1 py-2 rounded-lg transition-all text-center ${
            activeSubTab === 'upcoming'
              ? 'bg-white text-slate-900 shadow-xs'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          Upcoming ({upcomingAppointments.length})
        </button>
        <button
          onClick={() => setActiveSubTab('past')}
          className={`flex-1 py-2 rounded-lg transition-all text-center ${
            activeSubTab === 'past'
              ? 'bg-white text-slate-900 shadow-xs'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          History & Past ({pastAppointments.length})
        </button>
      </div>

      {/* Cancel Confirmation Dialog */}
      {cancellingId && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-2xl space-y-3 animate-in fade-in">
          <div className="flex items-center gap-2 text-xs font-bold text-red-900">
            <AlertTriangle className="w-4 h-4 text-red-600 shrink-0" />
            Cancel this appointment?
          </div>
          <p className="text-xs text-red-700">
            This will release the reserved stylist slot so other network customers can book.
          </p>
          <input
            type="text"
            value={cancelReason}
            onChange={e => setCancelReason(e.target.value)}
            placeholder="Reason for cancellation (optional)..."
            className="w-full text-xs p-2.5 rounded-xl border border-red-300 bg-white focus:outline-none focus:ring-1 focus:ring-red-500"
          />
          <div className="flex justify-end gap-2 pt-1">
            <AppButton size="sm" variant="outline" onClick={() => setCancellingId(null)}>
              Keep Appointment
            </AppButton>
            <AppButton size="sm" variant="danger" onClick={handleConfirmCancel}>
              Confirm Cancel
            </AppButton>
          </div>
        </div>
      )}

      {/* Appointment list content */}
      {activeSubTab === 'upcoming' && (
        <div className="space-y-3">
          {upcomingAppointments.length === 0 ? (
            <EmptyStateWidget
              icon={<Calendar className="w-8 h-8" />}
              title="No upcoming bookings"
              description="You have no scheduled appointments. Discover our branches and book your preferred stylist!"
              actionText="Book an Appointment"
              onAction={onStartBooking}
            />
          ) : (
            upcomingAppointments.map(apt => (
              <AppointmentCard
                key={apt.appointmentId}
                appointment={apt}
                onCancel={id => setCancellingId(id)}
              />
            ))
          )}
        </div>
      )}

      {activeSubTab === 'past' && (
        <div className="space-y-3">
          {pastAppointments.length === 0 ? (
            <EmptyStateWidget
              icon={<Scissors className="w-8 h-8" />}
              title="No past appointments"
              description="Your completed and historical visits across StyleHub branches will appear here."
            />
          ) : (
            pastAppointments.map(apt => (
              <AppointmentCard
                key={apt.appointmentId}
                appointment={apt}
                onRebook={a => onRebook(a)}
              />
            ))
          )}
        </div>
      )}
    </div>
  );
};
