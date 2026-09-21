import React, { useState } from 'react';
import { 
  X, 
  MapPin, 
  Scissors, 
  User, 
  Calendar as CalendarIcon, 
  Clock, 
  CheckCircle2, 
  ChevronRight, 
  ChevronLeft,
  Sparkles,
  AlertCircle
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { Branch, Stylist, SalonService, Appointment } from '../../types';
import { 
  useBranches, 
  useServices, 
  useStylists, 
  useStylistSlots, 
  bookingService 
} from '../../services/dataService';
import { useAuth } from '../../context/AuthContext';
import { AppButton } from '../common/AppButton';
import { AppCard } from '../common/AppCard';
import { BranchCard } from '../cards/BranchCard';
import { ServiceCard } from '../cards/ServiceCard';
import { StylistCard } from '../cards/StylistCard';

interface BookingFlowModalProps {
  isOpen: boolean;
  onClose: () => void;
  onBookingSuccess: (appointment: Appointment) => void;
  initialBranchId?: string;
  initialServiceId?: string;
  initialStylistId?: string;
}

export const BookingFlowModal: React.FC<BookingFlowModalProps> = ({
  isOpen,
  onClose,
  onBookingSuccess,
  initialBranchId,
  initialServiceId,
  initialStylistId,
}) => {
  const { currentUser } = useAuth();
  
  const { branches: allBranches } = useBranches();
  const { services: allServices } = useServices();
  const { stylists: allStylists } = useStylists();

  const branches = allBranches.filter(b => b.active);
  const services = allServices.filter(s => s.active);
  const stylists = allStylists.filter(s => s.active);

  // Flow step (1: Branch, 2: Service, 3: Stylist, 4: Date & Time, 5: Summary)
  const [step, setStep] = useState<number>(1);
  const [selectedBranch, setSelectedBranch] = useState<Branch | null>(
    branches.find(b => b.branchId === initialBranchId) || null
  );
  const [selectedService, setSelectedService] = useState<SalonService | null>(
    services.find(s => s.serviceId === initialServiceId) || null
  );
  const [selectedStylist, setSelectedStylist] = useState<Stylist | null>(
    stylists.find(s => s.stylistId === initialStylistId) || null
  );
  
  const todayStr = new Date().toISOString().split('T')[0];
  const [selectedDate, setSelectedDate] = useState<string>(todayStr);
  const [selectedTime, setSelectedTime] = useState<string>('');
  const [notes, setNotes] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [errorMsg, setErrorMsg] = useState<string>('');

  const bookedSlots = useStylistSlots(selectedStylist?.stylistId, selectedDate);

  if (!isOpen) return null;

  // Filter stylists available at the selected branch
  const availableStylists = selectedBranch
    ? stylists.filter(s => s.branchId === selectedBranch.branchId)
    : stylists;

  // Generate next 10 days for date picker
  const dateOptions = Array.from({ length: 10 }).map((_, i) => {
    const d = new Date();
    d.setDate(d.getDate() + i);
    const dateStr = d.toISOString().split('T')[0];
    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' });
    const dayNum = d.getDate();
    const month = d.toLocaleDateString('en-US', { month: 'short' });
    return { dateStr, dayName, dayNum, month };
  });

  // Time slots for selected stylist
  const timeSlots = selectedStylist?.availability || [
    '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:30 PM', '06:00 PM'
  ];

  const handleNext = () => {
    setErrorMsg('');
    if (step === 1 && !selectedBranch) {
      setErrorMsg('Please choose a salon branch.');
      return;
    }
    if (step === 2 && !selectedService) {
      setErrorMsg('Please select a service.');
      return;
    }
    if (step === 3 && !selectedStylist) {
      setErrorMsg('Please select a stylist.');
      return;
    }
    if (step === 4 && (!selectedDate || !selectedTime)) {
      setErrorMsg('Please select both a date and available time slot.');
      return;
    }
    setStep(prev => Math.min(prev + 1, 5));
  };

  const handlePrev = () => {
    setErrorMsg('');
    setStep(prev => Math.max(prev - 1, 1));
  };

  const handleConfirmBooking = async () => {
    if (!currentUser || !selectedBranch || !selectedService || !selectedStylist || !selectedTime) {
      setErrorMsg('Missing required booking parameters.');
      return;
    }

    setIsSubmitting(true);
    setErrorMsg('');

    try {
      // Create appointment through data service (enforces double-booking validation)
      const newApt = await bookingService.createAppointment({
        customerId: currentUser.uid,
        customerName: currentUser.name,
        customerPhone: currentUser.phone || '+91 98000 00000',
        customerEmail: currentUser.email,
        branchId: selectedBranch.branchId,
        branchName: selectedBranch.name,
        stylistId: selectedStylist.stylistId,
        stylistName: selectedStylist.name,
        serviceId: selectedService.serviceId,
        serviceName: selectedService.name,
        servicePrice: selectedService.price,
        serviceDuration: selectedService.duration,
        appointmentDate: selectedDate,
        startTime: selectedTime,
        notes,
      });

      // Celebration confetti
      try {
        confetti({
          particleCount: 80,
          spread: 70,
          origin: { y: 0.6 },
        });
      } catch {
        // Ignore canvas error if any
      }

      onBookingSuccess(newApt);
      onClose();
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : 'Unable to complete booking. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="bg-white w-full max-w-lg rounded-3xl shadow-2xl flex flex-col max-h-[92vh] overflow-hidden border border-slate-100">
        
        {/* Header */}
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
          <div>
            <span className="text-[11px] font-bold text-rose-600 uppercase tracking-widest">
              Step {step} of 5
            </span>
            <h3 className="text-base font-bold text-slate-900">
              {step === 1 && 'Select Salon Branch'}
              {step === 2 && 'Select Service'}
              {step === 3 && 'Choose Your Stylist'}
              {step === 4 && 'Choose Date & Time'}
              {step === 5 && 'Confirm Your Booking'}
            </h3>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-slate-200 text-slate-400 hover:text-slate-700 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Step progress bar */}
        <div className="w-full bg-slate-100 h-1">
          <div
            className="bg-rose-600 h-1 transition-all duration-300"
            style={{ width: `${(step / 5) * 100}%` }}
          />
        </div>

        {/* Error notification */}
        {errorMsg && (
          <div className="mx-5 mt-3 p-3 rounded-xl bg-red-50 border border-red-200 text-xs text-red-700 flex items-center gap-2">
            <AlertCircle className="w-4 h-4 shrink-0 text-red-500" />
            <span>{errorMsg}</span>
          </div>
        )}

        {/* Scrollable Content Body */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          
          {/* STEP 1: Select Branch */}
          {step === 1 && (
            <div className="space-y-3">
              <p className="text-xs text-slate-500">
                You can visit any branch across Pune with your unified StyleHub customer identity.
              </p>
              <div className="grid grid-cols-1 gap-3">
                {branches.map(branch => {
                  const isSelected = selectedBranch?.branchId === branch.branchId;
                  return (
                    <div
                      key={branch.branchId}
                      onClick={() => setSelectedBranch(branch)}
                      className={`p-3.5 rounded-2xl border-2 transition-all cursor-pointer flex items-center gap-3.5 ${
                        isSelected
                          ? 'border-rose-600 bg-rose-50/40 shadow-xs'
                          : 'border-slate-100 hover:border-slate-200 bg-white'
                      }`}
                    >
                      <img
                        src={branch.image}
                        alt={branch.name}
                        className="w-16 h-16 rounded-xl object-cover shrink-0"
                      />
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <span className="text-[10px] font-bold uppercase text-rose-600 tracking-wider">
                            {branch.city}
                          </span>
                          <span className="text-xs font-semibold text-amber-600">★ {branch.rating}</span>
                        </div>
                        <h4 className="text-sm font-bold text-slate-900 truncate">{branch.name}</h4>
                        <p className="text-xs text-slate-500 truncate mt-0.5">{branch.address}</p>
                      </div>
                      <div className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                        isSelected ? 'border-rose-600 bg-rose-600 text-white' : 'border-slate-300'
                      }`}>
                        {isSelected && <CheckCircle2 className="w-3.5 h-3.5" />}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 2: Select Service */}
          {step === 2 && (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <p className="text-xs text-slate-500">Browse treatments & services</p>
                {selectedBranch && (
                  <span className="text-[11px] font-semibold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-md">
                    {selectedBranch.name}
                  </span>
                )}
              </div>
              <div className="space-y-2.5">
                {services.map(srv => (
                  <ServiceCard
                    key={srv.serviceId}
                    service={srv}
                    compact
                    selected={selectedService?.serviceId === srv.serviceId}
                    onSelect={s => setSelectedService(s)}
                  />
                ))}
              </div>
            </div>
          )}

          {/* STEP 3: Select Stylist */}
          {step === 3 && (
            <div className="space-y-3">
              <p className="text-xs text-slate-500">
                Stylists available at {selectedBranch?.name || 'this location'}
              </p>
              {availableStylists.length === 0 ? (
                <div className="p-6 text-center text-xs text-slate-400">
                  No stylists assigned yet to this branch.
                </div>
              ) : (
                <div className="space-y-2.5">
                  {availableStylists.map(sty => (
                    <StylistCard
                      key={sty.stylistId}
                      stylist={sty}
                      compact
                      selected={selectedStylist?.stylistId === sty.stylistId}
                      onSelect={s => setSelectedStylist(s)}
                    />
                  ))}
                </div>
              )}
            </div>
          )}

          {/* STEP 4: Date & Time */}
          {step === 4 && (
            <div className="space-y-5">
              {/* Date selection horizontal scroll */}
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-2">
                  Select Date
                </label>
                <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1">
                  {dateOptions.map(opt => {
                    const isSelected = selectedDate === opt.dateStr;
                    return (
                      <button
                        key={opt.dateStr}
                        onClick={() => {
                          setSelectedDate(opt.dateStr);
                          setSelectedTime(''); // Reset time selection on date change
                        }}
                        className={`flex flex-col items-center justify-center p-3 rounded-2xl min-w-[62px] shrink-0 border transition-all ${
                          isSelected
                            ? 'bg-rose-600 text-white border-rose-600 shadow-sm'
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span className="text-[11px] font-medium opacity-80">{opt.dayName}</span>
                        <span className="text-lg font-bold">{opt.dayNum}</span>
                        <span className="text-[10px] uppercase font-semibold">{opt.month}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Time slots */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-xs font-semibold text-slate-700 uppercase tracking-wider">
                    Available Time Slots
                  </label>
                  <span className="text-[11px] text-slate-400">
                    With {selectedStylist?.name}
                  </span>
                </div>

                <div className="grid grid-cols-3 gap-2">
                  {timeSlots.map(time => {
                    const isBooked = bookedSlots.includes(time);
                    const isSelected = selectedTime === time;

                    return (
                      <button
                        key={time}
                        disabled={isBooked}
                        onClick={() => setSelectedTime(time)}
                        className={`py-2.5 px-2 rounded-xl text-xs font-medium border text-center transition-all ${
                          isBooked
                            ? 'bg-slate-100 text-slate-400 border-slate-200 cursor-not-allowed line-through'
                            : isSelected
                            ? 'bg-rose-600 text-white border-rose-600 font-semibold shadow-xs'
                            : 'bg-white text-slate-700 border-slate-200 hover:border-slate-300 hover:bg-slate-50'
                        }`}
                      >
                        {time}
                        {isBooked && <span className="block text-[9px] no-underline opacity-80">Booked</span>}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Special notes */}
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-1.5">
                  Styling Notes / Preferences (Optional)
                </label>
                <textarea
                  rows={2}
                  value={notes}
                  onChange={e => setNotes(e.target.value)}
                  placeholder="E.g., Hair type, skin sensitivity, or specific references..."
                  className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-rose-500/20 focus:border-rose-500"
                />
              </div>
            </div>
          )}

          {/* STEP 5: Summary */}
          {step === 5 && (
            <div className="space-y-4">
              <div className="p-4 rounded-2xl bg-rose-50/50 border border-rose-100/80 space-y-3">
                <div className="flex items-center justify-between pb-2 border-b border-rose-100">
                  <span className="text-xs font-bold text-rose-800 uppercase tracking-wider">
                    Booking Summary
                  </span>
                  <span className="text-xs font-bold text-rose-600 bg-white px-2 py-0.5 rounded-full border border-rose-200">
                    Instant Confirmation
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-3 text-xs">
                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">Salon Branch</span>
                    <span className="font-bold text-slate-900 flex items-center gap-1 mt-0.5">
                      <MapPin className="w-3 h-3 text-rose-500 shrink-0" />
                      {selectedBranch?.name}
                    </span>
                    <span className="text-slate-500 text-[11px] block">{selectedBranch?.city}</span>
                  </div>

                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">Stylist</span>
                    <span className="font-bold text-slate-900 flex items-center gap-1 mt-0.5">
                      <User className="w-3 h-3 text-slate-500 shrink-0" />
                      {selectedStylist?.name}
                    </span>
                    <span className="text-rose-600 text-[11px] block">{selectedStylist?.specialization}</span>
                  </div>

                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">Service</span>
                    <span className="font-bold text-slate-900 flex items-center gap-1 mt-0.5">
                      <Scissors className="w-3 h-3 text-slate-500 shrink-0" />
                      {selectedService?.name}
                    </span>
                    <span className="text-slate-500 text-[11px] block">{selectedService?.duration} minutes</span>
                  </div>

                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">Date & Time</span>
                    <span className="font-bold text-slate-900 flex items-center gap-1 mt-0.5">
                      <CalendarIcon className="w-3 h-3 text-slate-500 shrink-0" />
                      {selectedDate}
                    </span>
                    <span className="text-slate-700 font-semibold text-[11px] block">{selectedTime}</span>
                  </div>
                </div>

                {notes && (
                  <div className="pt-2 border-t border-rose-100 text-[11px] text-slate-600">
                    <span className="font-semibold text-slate-700">Notes: </span>
                    {notes}
                  </div>
                )}
              </div>

              {/* Customer Global ID Banner */}
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 text-xs flex items-center justify-between">
                <div>
                  <span className="text-[10px] font-bold text-slate-400 uppercase">Global Customer Identity</span>
                  <p className="font-semibold text-slate-800">{currentUser?.name} ({currentUser?.uid})</p>
                </div>
                <span className="text-[10px] bg-slate-200 text-slate-700 px-2 py-0.5 rounded-full font-semibold">
                  Cross-Branch Sync
                </span>
              </div>

              {/* Total price */}
              <div className="p-3 bg-slate-900 text-white rounded-2xl flex items-center justify-between">
                <div>
                  <span className="text-[10px] text-slate-400 uppercase tracking-wider block">Total Payable at Salon</span>
                  <span className="text-xs text-slate-300">Taxes & consultation included</span>
                </div>
                <span className="text-xl font-bold text-rose-400">₹{selectedService?.price}</span>
              </div>
            </div>
          )}
        </div>

        {/* Footer Navigation Controls */}
        <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between gap-3">
          {step > 1 ? (
            <AppButton
              variant="outline"
              size="sm"
              onClick={handlePrev}
              leftIcon={<ChevronLeft className="w-4 h-4" />}
            >
              Back
            </AppButton>
          ) : (
            <div />
          )}

          {step < 5 ? (
            <AppButton
              variant="primary"
              size="sm"
              onClick={handleNext}
              rightIcon={<ChevronRight className="w-4 h-4" />}
            >
              Next Step
            </AppButton>
          ) : (
            <AppButton
              variant="primary"
              size="md"
              isLoading={isSubmitting}
              onClick={handleConfirmBooking}
              leftIcon={<Sparkles className="w-4 h-4" />}
            >
              Confirm Appointment
            </AppButton>
          )}
        </div>
      </div>
    </div>
  );
};
