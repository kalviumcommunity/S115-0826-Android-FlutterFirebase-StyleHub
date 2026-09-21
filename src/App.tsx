import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Navbar } from './components/navigation/Navbar';
import { BottomNav } from './components/navigation/BottomNav';
import { CustomerHomeScreen } from './components/customer/CustomerHomeScreen';
import { CustomerAppointmentsScreen } from './components/customer/CustomerAppointmentsScreen';
import { CustomerHistoryScreen } from './components/customer/CustomerHistoryScreen';
import { CustomerProfileScreen } from './components/customer/CustomerProfileScreen';
import { BookingFlowModal } from './components/customer/BookingFlowModal';
import { StaffDashboard } from './components/staff/StaffDashboard';
import { AdminDashboard } from './components/admin/AdminDashboard';
import { AuthScreen } from './components/auth/AuthScreen';
import { Appointment } from './types';
import { ShieldCheck, CheckCircle2, ChevronDown, ChevronUp, Smartphone } from 'lucide-react';
import { FlutterArchitectureModal } from './components/flutter/FlutterArchitectureModal';

const ProtectedRoute: React.FC<{ children: React.ReactNode; allowedRoles?: string[] }> = ({ children, allowedRoles }) => {
  const { isAuthenticated, isLoading, role } = useAuth();
  const location = useLocation();

  if (isLoading) return <div className="flex items-center justify-center h-screen">Loading...</div>;
  if (!isAuthenticated) return <Navigate to="/login" state={{ from: location }} replace />;
  if (allowedRoles && !allowedRoles.includes(role)) return <Navigate to="/" replace />;
  return <>{children}</>;
};

const MainLayout: React.FC = () => {
  const { role, currentUser } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  
  const [isBookingOpen, setIsBookingOpen] = useState(false);
  const [bookingBranchId, setBookingBranchId] = useState<string | undefined>();
  const [bookingServiceId, setBookingServiceId] = useState<string | undefined>();
  const [bookingStylistId, setBookingStylistId] = useState<string | undefined>();
  const [isFlutterModalOpen, setIsFlutterModalOpen] = useState(false);
  const [showQaBanner, setShowQaBanner] = useState(true);
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
    navigate('/appointments');
  };

  // Determine active tab for BottomNav
  let activeTab: any = 'home';
  if (location.pathname === '/appointments') activeTab = 'appointments';
  else if (location.pathname === '/history') activeTab = 'history';
  else if (location.pathname === '/profile') activeTab = 'profile';

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col items-center justify-start text-slate-800">
      <div className="w-full max-w-lg min-h-screen bg-slate-50 flex flex-col shadow-xl relative border-x border-slate-200/70 pb-20">
        
        {role === 'customer' && (
          <Navbar
            onOpenBooking={() => handleStartBooking()}
            onNavigateHome={() => navigate('/')}
          />
        )}

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

        {toastMessage && (
          <div className="fixed top-14 left-1/2 -translate-x-1/2 z-50 bg-slate-900 text-white text-xs px-4 py-2.5 rounded-2xl shadow-xl flex items-center gap-2 border border-slate-700 animate-in fade-in slide-in-from-top-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span className="font-medium">{toastMessage}</span>
          </div>
        )}

        <main className="flex-1 p-4">
          <Routes>
            <Route path="/login" element={
               <AuthScreen />
            } />

            {/* CUSTOMER ROUTES */}
            <Route path="/" element={
              <ProtectedRoute allowedRoles={['customer']}>
                <CustomerHomeScreen onStartBooking={handleStartBooking} onViewAllAppointments={() => navigate('/appointments')} onViewHistory={() => navigate('/history')} />
              </ProtectedRoute>
            } />
            <Route path="/appointments" element={
              <ProtectedRoute allowedRoles={['customer']}>
                <CustomerAppointmentsScreen onStartBooking={() => handleStartBooking()} onRebook={handleRebook} />
              </ProtectedRoute>
            } />
            <Route path="/history" element={
              <ProtectedRoute allowedRoles={['customer']}>
                <CustomerHistoryScreen onRebook={handleRebook} onExploreBranches={() => navigate('/')} />
              </ProtectedRoute>
            } />
            <Route path="/profile" element={
              <ProtectedRoute allowedRoles={['customer']}>
                <CustomerProfileScreen onRoleSwitched={() => { /* Not used in real auth easily, redirecting */ navigate('/'); }} />
              </ProtectedRoute>
            } />

            {/* STAFF ROUTE */}
            <Route path="/staff" element={
              <ProtectedRoute allowedRoles={['staff']}>
                <StaffDashboard />
              </ProtectedRoute>
            } />

            {/* ADMIN ROUTE */}
            <Route path="/admin" element={
              <ProtectedRoute allowedRoles={['admin']}>
                <AdminDashboard />
              </ProtectedRoute>
            } />
            
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>

        {role === 'customer' && (
          <BottomNav activeCustomerTab={activeTab} onSelectCustomerTab={(tab) => navigate(tab === 'home' ? '/' : `/${tab}`)} />
        )}

        <BookingFlowModal
          isOpen={isBookingOpen}
          onClose={() => setIsBookingOpen(false)}
          onBookingSuccess={handleBookingSuccess}
          initialBranchId={bookingBranchId}
          initialServiceId={bookingServiceId}
          initialStylistId={bookingStylistId}
        />

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
    <BrowserRouter>
      <AuthProvider>
        <MainLayout />
      </AuthProvider>
    </BrowserRouter>
  );
}
