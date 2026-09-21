import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  Clock, 
  User, 
  MapPin, 
  Scissors, 
  CheckCircle2, 
  XCircle, 
  AlertCircle, 
  History, 
  ShieldCheck, 
  Filter, 
  Search,
  Check,
  Edit,
  Eye
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { 
  useBranches, 
  useStylists, 
  useAppointments, 
  useCustomerAppointments, 
  getCustomerNetworkProfile, 
  bookingService 
} from '../../services/dataService';
import { Appointment, AppointmentStatus, CustomerNetworkInsight } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { StatusBadge } from '../common/FeedbackWidgets';

export const StaffDashboard: React.FC = () => {
  const { currentUser, role } = useAuth();
  
  const { branches, loading: loadingBranches } = useBranches();
  const { stylists, loading: loadingStylists } = useStylists();

  // Branch context: default to staff's assigned branch or first branch
  const [selectedBranchId, setSelectedBranchId] = useState<string>(
    currentUser?.assignedBranchId || 'branch_baner'
  );

  // When branches load, if there's no selected branch or assigned branch, pick the first one
  useEffect(() => {
    if (!currentUser?.assignedBranchId && branches.length > 0 && selectedBranchId === 'branch_baner') {
      setSelectedBranchId(branches[0].branchId);
    }
  }, [branches, currentUser, selectedBranchId]);

  const [selectedStylistFilter, setSelectedStylistFilter] = useState<string>('all');
  const [dateFilter, setDateFilter] = useState<'today' | 'upcoming' | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Selected customer for Cross-Branch Recognition Modal
  const [inspectedCustomerId, setInspectedCustomerId] = useState<string | null>(null);

  // Edit notes state
  const [editingNotesAptId, setEditingNotesAptId] = useState<string | null>(null);
  const [notesInput, setNotesInput] = useState<string>('');

  const currentBranch = branches.find(b => b.branchId === selectedBranchId) || branches[0];
  
  const { appointments: branchAppointments, loading: loadingApts } = useAppointments(currentUser?.uid, role, selectedBranchId);
  const { customerAppointments: inspectedCustomerAllApts } = useCustomerAppointments(inspectedCustomerId);

  const todayStr = new Date().toISOString().split('T')[0];

  // Filter appointments
  const filteredAppointments = branchAppointments.filter(apt => {
    // Stylist filter
    if (selectedStylistFilter !== 'all' && apt.stylistId !== selectedStylistFilter) {
      return false;
    }
    // Date filter
    if (dateFilter === 'today' && apt.appointmentDate !== todayStr) {
      return false;
    }
    if (dateFilter === 'upcoming' && (apt.status === 'Completed' || apt.status === 'Cancelled')) {
      return false;
    }
    // Search query
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      return (
        apt.customerName.toLowerCase().includes(q) ||
        apt.serviceName.toLowerCase().includes(q) ||
        apt.stylistName.toLowerCase().includes(q) ||
        apt.customerId.toLowerCase().includes(q)
      );
    }
    return true;
  });

  const handleStatusChange = async (appointmentId: string, newStatus: AppointmentStatus) => {
    await bookingService.updateAppointmentStatus(appointmentId, newStatus);
  };

  const handleSaveNotes = async (appointmentId: string) => {
    const apt = branchAppointments.find(a => a.appointmentId === appointmentId);
    if (apt) {
      await bookingService.updateAppointmentStatus(appointmentId, apt.status, notesInput);
    }
    setEditingNotesAptId(null);
    setNotesInput('');
  };

  // Inspect customer cross-branch profile
  const inspectedProfile: CustomerNetworkInsight | null = inspectedCustomerId && inspectedCustomerAllApts.length > 0
    ? getCustomerNetworkProfile(inspectedCustomerAllApts, inspectedCustomerId) 
    : null;

  if (loadingBranches || loadingStylists || loadingApts) {
    return <div className="p-8 text-center text-slate-500 animate-pulse">Loading Dashboard...</div>;
  }

  return (
    <div className="space-y-5 pb-8">
      
      {/* Staff Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-white p-4 rounded-3xl border border-slate-100 shadow-2xs">
        <div>
          <span className="text-[10px] font-bold text-rose-600 uppercase tracking-widest flex items-center gap-1">
            <Scissors className="w-3 h-3" /> Staff Management Console
          </span>
          <h2 className="text-lg font-extrabold text-slate-900">
            {currentBranch?.name || 'Salon Branch'}
          </h2>
          <p className="text-xs text-slate-500">
            Logged in as {currentUser?.name} ({currentUser?.role.toUpperCase()})
          </p>
        </div>

        {/* Branch Switcher for Staff/Manager */}
        <div className="flex items-center gap-2">
          <label className="text-xs font-semibold text-slate-500 shrink-0">Branch:</label>
          <select
            value={selectedBranchId}
            onChange={e => setSelectedBranchId(e.target.value)}
            className="text-xs font-bold bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-800 focus:outline-none focus:ring-2 focus:ring-rose-500"
          >
            {branches.map(b => (
              <option key={b.branchId} value={b.branchId}>
                {b.name} ({b.city})
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Cross-Branch Alert Banner */}
      <div className="p-3.5 bg-gradient-to-r from-slate-900 to-slate-800 text-white rounded-2xl flex items-center justify-between shadow-xs">
        <div className="flex items-center gap-2.5">
          <div className="p-2 rounded-xl bg-rose-500/20 text-rose-400">
            <History className="w-4 h-4" />
          </div>
          <div>
            <h4 className="text-xs font-bold">Cross-Branch Customer Recognition Active</h4>
            <p className="text-[11px] text-slate-300">
              Click &quot;Recognize Customer&quot; on any appointment to view their universal treatment history across Pune.
            </p>
          </div>
        </div>
      </div>

      {/* Filters Bar */}
      <div className="flex flex-col sm:flex-row gap-3">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search by customer name, UID, service, or stylist..."
            className="w-full pl-10 pr-4 py-2 bg-white border border-slate-200 rounded-xl text-xs text-slate-800 focus:outline-none focus:ring-2 focus:ring-rose-500/20 focus:border-rose-500"
          />
        </div>

        {/* Date Filter Tabs */}
        <div className="flex rounded-xl bg-slate-100 p-1 text-xs font-semibold shrink-0">
          <button
            onClick={() => setDateFilter('today')}
            className={`px-3 py-1.5 rounded-lg transition ${
              dateFilter === 'today' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
            }`}
          >
            Today
          </button>
          <button
            onClick={() => setDateFilter('upcoming')}
            className={`px-3 py-1.5 rounded-lg transition ${
              dateFilter === 'upcoming' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
            }`}
          >
            Active
          </button>
          <button
            onClick={() => setDateFilter('all')}
            className={`px-3 py-1.5 rounded-lg transition ${
              dateFilter === 'all' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
            }`}
          >
            All Bookings
          </button>
        </div>

        {/* Stylist Filter */}
        <div className="shrink-0">
          <select
            value={selectedStylistFilter}
            onChange={e => setSelectedStylistFilter(e.target.value)}
            className="w-full text-xs font-medium bg-white border border-slate-200 rounded-xl px-3 py-2 text-slate-700 focus:outline-none focus:ring-2 focus:ring-rose-500"
          >
            <option value="all">All Stylists</option>
            {stylists.filter(s => s.branchId === selectedBranchId).map(s => (
              <option key={s.stylistId} value={s.stylistId}>
                {s.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Appointment Schedule List */}
      <div className="space-y-3">
        {filteredAppointments.length === 0 ? (
          <div className="p-8 text-center bg-white rounded-2xl border border-dashed border-slate-200">
            <Calendar className="w-8 h-8 text-slate-300 mx-auto mb-2" />
            <p className="text-xs text-slate-500">No appointments matching current filters.</p>
          </div>
        ) : (
          filteredAppointments.map(apt => {
            // Check if customer is a recognized repeat customer (local approximation using branch data)
            const custInsight = getCustomerNetworkProfile(branchAppointments, apt.customerId);
            const isCrossBranch = custInsight && custInsight.isCrossBranchCustomer;

            return (
              <AppCard
                key={apt.appointmentId}
                padding="md"
                className={`space-y-3 border-l-4 ${
                  apt.status === 'Confirmed'
                    ? 'border-l-emerald-500'
                    : apt.status === 'Pending'
                    ? 'border-l-amber-500'
                    : apt.status === 'Completed'
                    ? 'border-l-blue-500'
                    : 'border-l-slate-300'
                }`}
              >
                {/* Header row */}
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="text-sm font-bold text-slate-900">{apt.customerName}</h4>
                      
                      {/* Cross-Branch Recognition Badge! */}
                      {isCrossBranch ? (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 text-[10px] font-bold border border-rose-200">
                          <ShieldCheck className="w-3 h-3 text-rose-600" />
                          Multi-Branch Client ({custInsight.branchesVisited.length} Outlets)
                        </span>
                      ) : custInsight && custInsight.isRepeatCustomer ? (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 text-[10px] font-bold border border-amber-200">
                          Repeat Customer
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-[10px] font-medium">
                          New Client
                        </span>
                      )}
                    </div>

                    <div className="flex items-center gap-3 text-xs text-slate-500 mt-1">
                      <span>UID: <span className="font-mono font-medium text-slate-700">{apt.customerId}</span></span>
                      <span>•</span>
                      <span>{apt.customerPhone}</span>
                    </div>
                  </div>

                  <StatusBadge status={apt.status} />
                </div>

                {/* Service and Stylist Information */}
                <div className="p-3 bg-slate-50/70 rounded-xl flex items-center justify-between text-xs">
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Service Booked</span>
                    <span className="font-bold text-slate-900">{apt.serviceName}</span>
                    <span className="text-slate-500 ml-2">₹{apt.servicePrice}</span>
                  </div>
                  <div className="text-right">
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Assigned Stylist</span>
                    <span className="font-bold text-slate-800">{apt.stylistName}</span>
                  </div>
                </div>

                {/* Timing */}
                <div className="flex items-center justify-between text-xs text-slate-600">
                  <div className="flex items-center gap-1.5">
                    <Calendar className="w-3.5 h-3.5 text-slate-400" />
                    <span>{apt.appointmentDate}</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Clock className="w-3.5 h-3.5 text-slate-400" />
                    <span className="font-semibold text-slate-800">{apt.startTime} - {apt.endTime}</span>
                  </div>
                </div>

                {/* Stylist Notes / Formulation / Preferences */}
                {editingNotesAptId === apt.appointmentId ? (
                  <div className="space-y-2 pt-2 border-t border-slate-100">
                    <label className="text-[11px] font-bold text-slate-700">Update Stylist Notes:</label>
                    <textarea
                      rows={2}
                      value={notesInput}
                      onChange={e => setNotesInput(e.target.value)}
                      placeholder="Enter color code, haircut guard size, hair texture, skin preferences..."
                      className="w-full text-xs p-2.5 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-rose-500"
                    />
                    <div className="flex justify-end gap-2">
                      <AppButton size="sm" variant="ghost" onClick={() => setEditingNotesAptId(null)}>
                        Cancel
                      </AppButton>
                      <AppButton size="sm" variant="primary" onClick={() => handleSaveNotes(apt.appointmentId)}>
                        Save Note
                      </AppButton>
                    </div>
                  </div>
                ) : (
                  <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-xs">
                    <p className="text-slate-600 text-[11px] italic truncate flex-1">
                      {apt.notes ? `Note: ${apt.notes}` : 'No stylist notes entered yet.'}
                    </p>
                    <button
                      onClick={() => {
                        setEditingNotesAptId(apt.appointmentId);
                        setNotesInput(apt.notes || '');
                      }}
                      className="text-xs text-rose-600 hover:text-rose-700 font-semibold flex items-center gap-1 shrink-0 ml-2"
                    >
                      <Edit className="w-3 h-3" /> {apt.notes ? 'Edit' : 'Add Note'}
                    </button>
                  </div>
                )}

                {/* Staff Actions Bar */}
                <div className="pt-3 border-t border-slate-100 flex flex-wrap items-center justify-between gap-2">
                  {/* Recognize Customer Button */}
                  <AppButton
                    size="sm"
                    variant="outline"
                    leftIcon={<Eye className="w-3.5 h-3.5 text-rose-600" />}
                    onClick={() => setInspectedCustomerId(apt.customerId)}
                  >
                    View Network History
                  </AppButton>

                  {/* Status transitions */}
                  <div className="flex items-center gap-2 ml-auto">
                    {apt.status === 'Pending' && (
                      <AppButton
                        size="sm"
                        variant="secondary"
                        leftIcon={<Check className="w-3.5 h-3.5" />}
                        onClick={() => handleStatusChange(apt.appointmentId, 'Confirmed')}
                      >
                        Confirm Slot
                      </AppButton>
                    )}

                    {apt.status === 'Confirmed' && (
                      <>
                        <AppButton
                          size="sm"
                          variant="primary"
                          leftIcon={<CheckCircle2 className="w-3.5 h-3.5" />}
                          onClick={() => handleStatusChange(apt.appointmentId, 'Completed')}
                        >
                          Mark Completed
                        </AppButton>
                        <AppButton
                          size="sm"
                          variant="danger"
                          onClick={() => handleStatusChange(apt.appointmentId, 'Cancelled')}
                        >
                          Cancel
                        </AppButton>
                      </>
                    )}

                    {apt.status === 'Completed' && (
                      <span className="text-xs font-semibold text-emerald-700 flex items-center gap-1">
                        <CheckCircle2 className="w-3.5 h-3.5" /> Service Finished
                      </span>
                    )}
                  </div>
                </div>
              </AppCard>
            );
          })
        )}
      </div>

      {/* CROSS-BRANCH CUSTOMER RECOGNITION MODAL (SOLVES CORE SPECIFICATION) */}
      {inspectedCustomerId && inspectedProfile && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-3 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-lg rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden border border-slate-100">
            
            {/* Modal Header */}
            <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-900 text-white">
              <div>
                <span className="text-[10px] font-bold text-rose-400 uppercase tracking-widest flex items-center gap-1">
                  <ShieldCheck className="w-3.5 h-3.5" /> StyleHub Global Identity Record
                </span>
                <h3 className="text-base font-bold text-white">
                  {inspectedProfile.customerName}
                </h3>
                <p className="text-xs text-slate-400 font-mono">UID: {inspectedProfile.customerId}</p>
              </div>
              <button
                onClick={() => setInspectedCustomerId(null)}
                className="p-1.5 rounded-full hover:bg-white/20 text-white transition"
              >
                <XCircle className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-5 space-y-4">
              
              {/* Network recognition overview */}
              <div className="p-4 rounded-2xl bg-rose-50/60 border border-rose-100 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-rose-900">Network Loyalty Summary</span>
                  <span className="text-[10px] font-bold bg-rose-600 text-white px-2 py-0.5 rounded-full">
                    {inspectedProfile.isCrossBranchCustomer ? 'Multi-Outlet Customer' : 'Single Outlet'}
                  </span>
                </div>

                <div className="grid grid-cols-3 gap-2 text-center">
                  <div className="p-2 bg-white rounded-xl border border-rose-100">
                    <span className="text-[10px] text-slate-400 uppercase block font-semibold">Total Visits</span>
                    <span className="text-lg font-bold text-slate-900">{inspectedProfile.totalBookings}</span>
                  </div>
                  <div className="p-2 bg-white rounded-xl border border-rose-100">
                    <span className="text-[10px] text-slate-400 uppercase block font-semibold">Outlets</span>
                    <span className="text-lg font-bold text-rose-600">{inspectedProfile.branchesVisited.length}</span>
                  </div>
                  <div className="p-2 bg-white rounded-xl border border-rose-100">
                    <span className="text-[10px] text-slate-400 uppercase block font-semibold">Spend</span>
                    <span className="text-lg font-bold text-slate-900">₹{inspectedProfile.totalSpent}</span>
                  </div>
                </div>

                {/* Branches visited list */}
                <div className="text-xs">
                  <span className="text-slate-500 block text-[11px] font-medium mb-1">
                    Outlets Visited Across Network:
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {inspectedProfile.branchesVisited.map((b, i) => (
                      <span
                        key={i}
                        className="bg-white px-2.5 py-1 rounded-lg border border-slate-200 font-semibold text-slate-800 text-xs flex items-center gap-1"
                      >
                        <MapPin className="w-3 h-3 text-rose-500" />
                        {b}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Complete cross-branch historical timeline */}
              <div>
                <h4 className="text-xs font-bold text-slate-800 uppercase tracking-wider mb-2.5">
                  Complete Cross-Branch Service History
                </h4>

                <div className="space-y-2.5">
                  {inspectedCustomerAllApts.map(a => (
                    <div
                      key={a.appointmentId}
                      className="p-3 bg-white rounded-xl border border-slate-200 text-xs space-y-1.5 shadow-2xs"
                    >
                      <div className="flex items-center justify-between font-bold text-slate-800">
                        <span className="flex items-center gap-1 text-rose-700">
                          <MapPin className="w-3 h-3" />
                          {a.branchName}
                        </span>
                        <StatusBadge status={a.status} size="sm" />
                      </div>

                      <div className="flex items-center justify-between text-slate-700">
                        <span className="font-semibold">{a.serviceName}</span>
                        <span>₹{a.servicePrice}</span>
                      </div>

                      <div className="flex items-center justify-between text-[11px] text-slate-500">
                        <span>Stylist: {a.stylistName}</span>
                        <span>{a.appointmentDate} • {a.startTime}</span>
                      </div>

                      {a.notes && (
                        <p className="text-[11px] text-slate-600 bg-slate-50 p-1.5 rounded border border-slate-100 italic">
                          Stylist formulation / notes: {a.notes}
                        </p>
                      )}
                    </div>
                  ))}
                </div>
              </div>

            </div>

            {/* Modal Footer */}
            <div className="p-4 border-t border-slate-100 bg-slate-50 flex justify-end">
              <AppButton
                size="sm"
                variant="secondary"
                onClick={() => setInspectedCustomerId(null)}
              >
                Close History
              </AppButton>
            </div>

          </div>
        </div>
      )}

    </div>
  );
};
