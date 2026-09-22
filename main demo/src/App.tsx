import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Navbar } from './components/navigation/Navbar';
import { BottomNav, CustomerTab } from './components/navigation/BottomNav';
import { CustomerHomeScreen } from './components/customer/CustomerHomeScreen';
import { CustomerAppointmentsScreen } from './components/customer/CustomerAppointmentsScreen';
import { CustomerHistoryScreen } from './components/customer/CustomerHistoryScreen';
import { CustomerProfileScreen } from './components/customer/CustomerProfileScreen';
import { BookingFlowModal } from './components/customer/BookingFlowModal';
import { StaffDashboard } from './components/staff/StaffDashboard';
import { AdminDashboard } from './components/admin/AdminDashboard';
import { AuthScreen } from './components/auth/AuthScreen';
import { dataService } from './services/dataService';
import { Appointment } from './types';
import { Sparkles, ShieldCheck, CheckCircle2, ChevronDown, ChevronUp, Layers, HelpCircle, Smartphone } from 'lucide-react';
import { FlutterArchitectureModal } from './components/flutter/FlutterArchitectureModal';

const MainLayout: React.FC = () => {
  const { role, isAuthenticated, currentUser, switchRole } = useAuth();
  
  // Navigation state for customer
  const [customerTab, setCustomerTab] = useState<CustomerTab>('home');
  
  // Booking modal state
  const [isBookingOpen, setIsBookingOpen] = useState(false);
  const [bookingBranchId, setBookingBranchId] = useState<string | undefined>();
  const [bookingServiceId, setBookingServiceId] = useState<string | undefined>();
  const [bookingStylistId, setBookingStylistId] = useState<string | undefined>();

  // Flutter Codebase architecture inspector modal state
  const [isFlutterModalOpen, setIsFlutterModalOpen] = useState(false);

  // Live QA Verification banner collapse state
  const [showQaBanner, setShowQaBanner] = useState(true);

  // Success toast for bookings
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleStartBooking = (branchId?: string, serviceId?: string, stylistId?: string) => {
    setBookingBranchId(branchId);
    setBookingServiceId(serviceId);
    setBookingStylistId(stylistId);
    setIsBookingOpen(true);
  };

  const handleRebook = (apt: Appointment) => {
    setBookingBranchId(apt.branchId);
    setBookingServiceId(apt.serviceId);
    setBookingStylistId(apt.stylistId);
    setIsBookingOpen(true);
  };

  const handleBookingSuccess = (apt: Appointment) => {
    showToast(`Appointment confirmed at ${apt.branchName} for ${apt.appointmentDate} at ${apt.startTime}!`);
    setCustomerTab('appointments');
  };

  if (!isAuthenticated) {
    return <AuthScreen />;
  }

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col items-center justify-start text-slate-800">
      
      {/* Mobile container simulator with responsive width */}
      <div className="w-full max-w-lg min-h-screen bg-slate-50 flex flex-col shadow-xl relative border-x border-slate-200/70 pb-20">
        
        {/* Top App Bar */}
        <Navbar
          onOpenBooking={() => handleStartBooking()}
          onNavigateHome={() => setCustomerTab('home')}
        />

        {/* Global Architecture & QA Verification Guide Banner */}
        <div className="bg-slate-900 text-white text-xs border-b border-slate-800">
          <button
            onClick={() => setShowQaBanner(!showQaBanner)}
            className="w-full px-4 py-2 flex items-center justify-between hover:bg-slate-800/80 transition"
          >
            <div className="flex items-center gap-1.5 font-bold text-rose-400">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Multi-Branch Verification Guide</span>
            </div>
            <div className="flex items-center gap-1 text-[11px] text-slate-400">
              <span>{showQaBanner ? 'Hide' : 'Show Flow Guide'}</span>
              {showQaBanner ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
            </div>
          </button>

          {showQaBanner && (
            <div className="px-4 pb-3 space-y-2 border-t border-slate-800/60 bg-slate-950/40 text-[11px] leading-relaxed text-slate-300">
              <p>
                <strong className="text-white">Centralized Identity:</strong> Customer <span className="text-rose-300 font-semibold">{currentUser?.name}</span> holds UID <span className="font-mono text-amber-300">{currentUser?.uid}</span>, unified across all salon outlets.
              </p>
              <div className="flex flex-wrap gap-1.5 pt-1">
                <button
                  onClick={() => {
                    switchRole('customer');
                    setCustomerTab('history');
                  }}
                  className="px-2 py-1 rounded-md bg-rose-600 text-white font-semibold hover:bg-rose-500 transition"
                >
                  1. View Cross-Branch History
                </button>
                <button
                  onClick={() => switchRole('staff')}
                  className="px-2 py-1 rounded-md bg-blue-600 text-white font-semibold hover:bg-blue-500 transition"
                >
                  2. Open Staff Console
                </button>
                <button
                  onClick={() => switchRole('admin')}
                  className="px-2 py-1 rounded-md bg-amber-600 text-white font-semibold hover:bg-amber-500 transition"
                >
                  3. Open HQ Analytics
                </button>
                <button
                  onClick={() => setIsFlutterModalOpen(true)}
                  className="px-2 py-1 rounded-md bg-purple-600 text-white font-semibold hover:bg-purple-500 transition flex items-center gap-1"
                >
                  <Smartphone className="w-3 h-3" />
                  <span>Inspect Flutter /lib Codebase</span>
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Dynamic Toast Message */}
        {toastMessage && (
          <div className="fixed top-14 left-1/2 -translate-x-1/2 z-50 bg-slate-900 text-white text-xs px-4 py-2.5 rounded-2xl shadow-xl flex items-center gap-2 border border-slate-700 animate-in fade-in slide-in-from-top-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span className="font-medium">{toastMessage}</span>
          </div>
        )}

        {/* Main Content Area */}
        <main className="flex-1 p-4">
          
          {/* CUSTOMER ROLE SCREENS */}
          {role === 'customer' && (
            <>
              {customerTab === 'home' && (
                <CustomerHomeScreen
                  onStartBooking={handleStartBooking}
                  onViewAllAppointments={() => setCustomerTab('appointments')}
                  onViewHistory={() => setCustomerTab('history')}
                />
              )}

              {customerTab === 'appointments' && (
                <CustomerAppointmentsScreen
                  onStartBooking={() => handleStartBooking()}
                  onRebook={handleRebook}
                />
              )}

              {customerTab === 'history' && (
                <CustomerHistoryScreen
                  onRebook={handleRebook}
                  onExploreBranches={() => setCustomerTab('home')}
                />
              )}

              {customerTab === 'profile' && (
                <CustomerProfileScreen
                  onRoleSwitched={() => setCustomerTab('home')}
                />
              )}
            </>
          )}

          {/* STAFF ROLE SCREEN */}
          {role === 'staff' && <StaffDashboard />}

          {/* ADMIN ROLE SCREEN */}
          {role === 'admin' && <AdminDashboard />}
        </main>

        {/* Customer Bottom Navigation Bar */}
        <BottomNav
          activeCustomerTab={customerTab}
          onSelectCustomerTab={setCustomerTab}
        />

        {/* Guided Booking Flow Modal */}
        <BookingFlowModal
          isOpen={isBookingOpen}
          onClose={() => setIsBookingOpen(false)}
          onBookingSuccess={handleBookingSuccess}
          initialBranchId={bookingBranchId}
          initialServiceId={bookingServiceId}
          initialStylistId={bookingStylistId}
        />

        {/* Flutter Architecture & Codebase Inspector Modal */}
        <FlutterArchitectureModal
          isOpen={isFlutterModalOpen}
          onClose={() => setIsFlutterModalOpen(false)}
        />

      </div>
    </div>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <MainLayout />
    </AuthProvider>
  );
}
