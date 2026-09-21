import React, { useState } from 'react';
import { 
  History, 
  MapPin, 
  User, 
  Scissors, 
  Calendar, 
  RotateCcw, 
  Sparkles, 
  ShieldCheck,
  CheckCircle,
  Building,
  TrendingUp,
  Tag
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useAppointments, useBranches, getCustomerNetworkProfile } from '../../services/dataService';
import { Appointment } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { StatusBadge } from '../common/FeedbackWidgets';

interface CustomerHistoryScreenProps {
  onRebook: (appointment: Appointment) => void;
  onExploreBranches: () => void;
}

export const CustomerHistoryScreen: React.FC<CustomerHistoryScreenProps> = ({
  onRebook,
  onExploreBranches,
}) => {
  const { currentUser, role } = useAuth();
  const [selectedBranchFilter, setSelectedBranchFilter] = useState<string>('all');

  const { appointments, loading: loadingApts } = useAppointments(currentUser?.uid, role);
  const { branches, loading: loadingBranches } = useBranches();

  const historyAppointments = appointments.filter(a => a.status === 'Completed');

  const networkProfile = currentUser 
    ? getCustomerNetworkProfile(appointments, currentUser.uid) 
    : null;

  const filteredHistory = selectedBranchFilter === 'all'
    ? historyAppointments
    : historyAppointments.filter(a => a.branchId === selectedBranchFilter);

  if (loadingApts || loadingBranches) {
    return <div className="p-8 text-center text-slate-500 animate-pulse">Loading history...</div>;
  }

  return (
    <div className="space-y-5 pb-6">
      
      {/* Header */}
      <div>
        <span className="text-[11px] font-bold text-rose-600 uppercase tracking-widest flex items-center gap-1">
          <History className="w-3.5 h-3.5" /> Centralized Network Ledger
        </span>
        <h2 className="text-xl font-extrabold text-slate-900 tracking-tight">
          Cross-Branch Service History
        </h2>
        <p className="text-xs text-slate-500">
          Universal timeline tracked by your single global customer identity (UID: {currentUser?.uid || 'GUEST'})
        </p>
      </div>

      {/* Network Loyalty & Cross-Branch Recognition Metrics */}
      {networkProfile && (
        <div className="grid grid-cols-2 gap-2.5">
          <div className="p-3.5 rounded-2xl bg-white border border-slate-100 shadow-2xs space-y-1">
            <div className="flex items-center gap-1.5 text-xs text-slate-400 font-medium">
              <Building className="w-3.5 h-3.5 text-rose-500" />
              <span>Branches Visited</span>
            </div>
            <div className="flex items-baseline gap-1.5">
              <span className="text-xl font-extrabold text-slate-900">
                {networkProfile.branchesVisited.length}
              </span>
              <span className="text-[11px] text-emerald-600 font-bold">
                {networkProfile.isCrossBranchCustomer ? 'Multi-Outlet VIP' : 'Single Outlet'}
              </span>
            </div>
            <p className="text-[10px] text-slate-400 truncate">
              {networkProfile.branchesVisited.join(', ') || 'None yet'}
            </p>
          </div>

          <div className="p-3.5 rounded-2xl bg-white border border-slate-100 shadow-2xs space-y-1">
            <div className="flex items-center gap-1.5 text-xs text-slate-400 font-medium">
              <TrendingUp className="w-3.5 h-3.5 text-amber-500" />
              <span>Completed Visits</span>
            </div>
            <div className="flex items-baseline gap-1.5">
              <span className="text-xl font-extrabold text-slate-900">
                {networkProfile.completedBookings}
              </span>
              <span className="text-[11px] text-rose-600 font-bold">
                {networkProfile.isRepeatCustomer ? 'Repeat Client' : 'First-time'}
              </span>
            </div>
            <p className="text-[10px] text-slate-400 truncate">
              Favorite: {networkProfile.favoriteService}
            </p>
          </div>
        </div>
      )}

      {/* Cross-Branch Guarantee Banner */}
      <div className="p-3.5 rounded-2xl bg-amber-50/70 border border-amber-200/80 text-amber-900 text-xs flex items-start gap-2.5">
        <ShieldCheck className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
        <div className="leading-relaxed">
          <span className="font-bold block text-amber-950">Zero Customer Fragmentation</span>
          No matter which StyleHub branch you visit in Pune, our stylists know your treatment history, preferred cuts, and skin profile.
        </div>
      </div>

      {/* Filter by Branch (default to all) */}
      <div className="flex items-center justify-between pt-1">
        <span className="text-xs font-bold text-slate-700 uppercase tracking-wider">
          Filter Timeline
        </span>
        <select
          value={selectedBranchFilter}
          onChange={e => setSelectedBranchFilter(e.target.value)}
          className="text-xs font-semibold bg-white border border-slate-200 rounded-xl px-2.5 py-1.5 text-slate-700 focus:outline-none focus:ring-1 focus:ring-rose-500"
        >
          <option value="all">All Outlets ({historyAppointments.length})</option>
          {branches.map(b => (
            <option key={b.branchId} value={b.branchId}>
              {b.name}
            </option>
          ))}
        </select>
      </div>

      {/* Network Timeline List */}
      {filteredHistory.length === 0 ? (
        <div className="p-8 text-center bg-slate-50 rounded-2xl border border-dashed border-slate-200">
          <History className="w-8 h-8 text-slate-400 mx-auto mb-2" />
          <h4 className="text-sm font-bold text-slate-800">No service history yet</h4>
          <p className="text-xs text-slate-500 mt-1 max-w-xs mx-auto">
            Once your appointments are marked completed by our salon staff, they will appear on this universal ledger.
          </p>
        </div>
      ) : (
        <div className="space-y-3 relative before:absolute before:left-6 before:top-4 before:bottom-4 before:w-0.5 before:bg-slate-200">
          {filteredHistory.map((apt, index) => (
            <div key={apt.appointmentId} className="relative pl-12">
              
              {/* Timeline marker icon */}
              <div className="absolute left-4 -translate-x-1/2 top-4 w-5 h-5 rounded-full bg-rose-600 text-white flex items-center justify-center text-[10px] shadow-xs ring-4 ring-white">
                <CheckCircle className="w-3 h-3" />
              </div>

              {/* Card Container */}
              <AppCard padding="md" className="border-l-4 border-l-rose-600 space-y-3 hover:shadow-xs">
                
                {/* Branch and Date Header */}
                <div className="flex items-center justify-between text-xs">
                  <div className="flex items-center gap-1.5 font-bold text-slate-800">
                    <MapPin className="w-3.5 h-3.5 text-rose-500" />
                    <span>{apt.branchName}</span>
                  </div>
                  <div className="flex items-center gap-1 text-slate-500">
                    <Calendar className="w-3 h-3 text-slate-400" />
                    <span>{apt.appointmentDate}</span>
                  </div>
                </div>

                {/* Service and Stylist Detail */}
                <div className="flex items-start justify-between">
                  <div>
                    <h4 className="text-sm font-extrabold text-slate-900">{apt.serviceName}</h4>
                    <p className="text-xs text-slate-600 flex items-center gap-1 mt-0.5">
                      <User className="w-3 h-3 text-slate-400" />
                      Stylist: <span className="font-semibold text-rose-600">{apt.stylistName}</span>
                    </p>
                  </div>
                  <span className="text-sm font-bold text-slate-900">₹{apt.servicePrice}</span>
                </div>

                {/* Treatment Notes */}
                {apt.notes && (
                  <p className="text-xs text-slate-500 bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                    <span className="font-semibold text-slate-700">Stylist Notes: </span>
                    {apt.notes}
                  </p>
                )}

                {/* Rebook Action */}
                <div className="pt-2 border-t border-slate-100 flex items-center justify-between">
                  <span className="text-[10px] text-emerald-700 font-bold bg-emerald-50 px-2 py-0.5 rounded-full">
                    Completed at Salon
                  </span>

                  <AppButton
                    size="sm"
                    variant="outline"
                    onClick={() => onRebook(apt)}
                    leftIcon={<RotateCcw className="w-3 h-3" />}
                  >
                    Repeat This Service
                  </AppButton>
                </div>
              </AppCard>
            </div>
          ))}
        </div>
      )}

      {/* Network Exploration Suggestion */}
      <div className="p-4 rounded-2xl bg-slate-900 text-white flex items-center justify-between">
        <div>
          <h4 className="text-xs font-bold">Travelling to a new neighborhood?</h4>
          <p className="text-[11px] text-slate-300">Book in Koregaon Park, Baner, Wakad, or Hadapsar</p>
        </div>
        <AppButton size="sm" variant="gold" onClick={onExploreBranches}>
          Explore Outlets
        </AppButton>
      </div>

    </div>
  );
};
