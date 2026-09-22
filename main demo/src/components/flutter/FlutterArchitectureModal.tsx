import React, { useState } from 'react';
import { Layers, FileCode, Check, Copy, Folder, ChevronRight, Sparkles, Database, Shield, Smartphone } from 'lucide-react';

interface FlutterFileNode {
  path: string;
  name: string;
  type: 'file' | 'folder';
  description: string;
  category: 'core' | 'models' | 'services' | 'repositories' | 'providers' | 'screens' | 'routes' | 'root';
}

const FLUTTER_FILES: FlutterFileNode[] = [
  { path: 'pubspec.yaml', name: 'pubspec.yaml', type: 'file', description: 'Dependencies: firebase_core, firebase_auth, cloud_firestore, firebase_storage, provider, google_fonts', category: 'root' },
  { path: 'lib/main.dart', name: 'main.dart', type: 'file', description: 'App entrypoint, MultiProvider setup, Firebase initialization, MaterialApp routing', category: 'root' },
  { path: 'lib/routes/app_routes.dart', name: 'app_routes.dart', type: 'file', description: 'Named routes configuration for splash, auth, customer, staff, and admin flows', category: 'routes' },
  
  // Core
  { path: 'lib/core/constants/app_constants.dart', name: 'app_constants.dart', type: 'file', description: 'Collections, storage paths, status constants, time slots', category: 'core' },
  { path: 'lib/core/theme/app_colors.dart', name: 'app_colors.dart', type: 'file', description: 'Centralized luxury salon color palette (Rose 600, Slate 900)', category: 'core' },
  { path: 'lib/core/theme/app_typography.dart', name: 'app_typography.dart', type: 'file', description: 'Playfair Display display fonts and Plus Jakarta Sans body fonts', category: 'core' },
  { path: 'lib/core/theme/app_theme.dart', name: 'app_theme.dart', type: 'file', description: 'Material3 ThemeData setup with custom component themes', category: 'core' },
  { path: 'lib/core/widgets/app_button.dart', name: 'app_button.dart', type: 'file', description: 'Reusable primary, secondary, outline button widget', category: 'core' },
  { path: 'lib/core/widgets/app_text_field.dart', name: 'app_text_field.dart', type: 'file', description: 'Standardized form input widget with validation styling', category: 'core' },
  { path: 'lib/core/widgets/app_card.dart', name: 'app_card.dart', type: 'file', description: 'Rounded elevated card container with subtle borders', category: 'core' },
  { path: 'lib/core/widgets/loading_widget.dart', name: 'loading_widget.dart', type: 'file', description: 'Centralized async loading indicator widget', category: 'core' },
  { path: 'lib/core/widgets/empty_state_widget.dart', name: 'empty_state_widget.dart', type: 'file', description: 'Empty state illustration and call-to-action widget', category: 'core' },
  { path: 'lib/core/widgets/confirmation_dialog.dart', name: 'confirmation_dialog.dart', type: 'file', description: 'Modal confirmation dialog for cancellation and logout', category: 'core' },
  { path: 'lib/core/exceptions/app_exceptions.dart', name: 'app_exceptions.dart', type: 'file', description: 'Custom typed exceptions for Auth, Firestore, and Booking Validation', category: 'core' },

  // Models
  { path: 'lib/models/user_model.dart', name: 'user_model.dart', type: 'file', description: 'Centralized Customer Identity model with Firestore serialization', category: 'models' },
  { path: 'lib/models/branch_model.dart', name: 'branch_model.dart', type: 'file', description: 'Salon branch outlet model with operating hours, rating, and address', category: 'models' },
  { path: 'lib/models/stylist_model.dart', name: 'stylist_model.dart', type: 'file', description: 'Stylist specialist profile with availability slots and experience', category: 'models' },
  { path: 'lib/models/service_model.dart', name: 'service_model.dart', type: 'file', description: 'Salon service catalogue item with pricing, duration, and category', category: 'models' },
  { path: 'lib/models/booking_model.dart', name: 'booking_model.dart', type: 'file', description: 'Draft booking transaction model for the 5-step checkout flow', category: 'models' },
  { path: 'lib/models/appointment_model.dart', name: 'appointment_model.dart', type: 'file', description: 'Cross-branch appointment record linking customer UID across salons', category: 'models' },

  // Services
  { path: 'lib/services/auth_service.dart', name: 'auth_service.dart', type: 'file', description: 'FirebaseAuth wrapper with friendly error mapping and auth streams', category: 'services' },
  { path: 'lib/services/firestore_service.dart', name: 'firestore_service.dart', type: 'file', description: 'Cloud Firestore CRUD and real-time query streams', category: 'services' },
  { path: 'lib/services/storage_service.dart', name: 'storage_service.dart', type: 'file', description: 'Firebase Storage upload service for profile and service images', category: 'services' },

  // Repositories
  { path: 'lib/repositories/auth_repository.dart', name: 'auth_repository.dart', type: 'file', description: 'Mediates between AuthService and Firestore user profile data', category: 'repositories' },
  { path: 'lib/repositories/booking_repository.dart', name: 'booking_repository.dart', type: 'file', description: 'Creates cross-branch bookings and validates centralized customer records', category: 'repositories' },
  { path: 'lib/repositories/branch_repository.dart', name: 'branch_repository.dart', type: 'file', description: 'Provides branch data streams and admin modifications', category: 'repositories' },
  { path: 'lib/repositories/stylist_repository.dart', name: 'stylist_repository.dart', type: 'file', description: 'Manages stylist availability and branch assignments', category: 'repositories' },
  { path: 'lib/repositories/service_repository.dart', name: 'service_repository.dart', type: 'file', description: 'Manages salon service catalogue items and pricing', category: 'repositories' },

  // Providers
  { path: 'lib/providers/auth_provider.dart', name: 'auth_provider.dart', type: 'file', description: 'ChangeNotifier managing customer/staff/admin session & centralized UID', category: 'providers' },
  { path: 'lib/providers/booking_provider.dart', name: 'booking_provider.dart', type: 'file', description: 'Manages 5-step draft booking state and cross-branch history streams', category: 'providers' },
  { path: 'lib/providers/branch_provider.dart', name: 'branch_provider.dart', type: 'file', description: 'Branch selection, search filtering, and outlet details', category: 'providers' },
  { path: 'lib/providers/stylist_provider.dart', name: 'stylist_provider.dart', type: 'file', description: 'Filter stylists by branch and track assigned bookings', category: 'providers' },
  { path: 'lib/providers/service_provider.dart', name: 'service_provider.dart', type: 'file', description: 'Category tabs filtering and service selection state', category: 'providers' },

  // Screens
  { path: 'lib/screens/splash/splash_screen.dart', name: 'splash_screen.dart', type: 'file', description: 'Animated splash screen checking Firebase auth state before routing', category: 'screens' },
  { path: 'lib/screens/auth/login_screen.dart', name: 'login_screen.dart', type: 'file', description: 'Login form with email/password validation and demo role shortcuts', category: 'screens' },
  { path: 'lib/screens/auth/signup_screen.dart', name: 'signup_screen.dart', type: 'file', description: 'Registration screen creating unified Firebase Auth user & Firestore doc', category: 'screens' },
  { path: 'lib/screens/customer/customer_main_screen.dart', name: 'customer_main_screen.dart', type: 'file', description: 'Bottom navigation shell: Home, Bookings, History, Profile', category: 'screens' },
  { path: 'lib/screens/customer/customer_home_screen.dart', name: 'customer_home_screen.dart', type: 'file', description: 'Customer dashboard displaying branches, services, and centralized UID banner', category: 'screens' },
  { path: 'lib/screens/customer/customer_appointments_screen.dart', name: 'customer_appointments_screen.dart', type: 'file', description: 'Upcoming appointments with cancel and status tracking', category: 'screens' },
  { path: 'lib/screens/customer/customer_history_screen.dart', name: 'customer_history_screen.dart', type: 'file', description: 'Centralized Cross-Branch History screen displaying all branch visits under one UID', category: 'screens' },
  { path: 'lib/screens/customer/customer_profile_screen.dart', name: 'customer_profile_screen.dart', type: 'file', description: 'Profile details with demo role switcher and sign-out dialog', category: 'screens' },
  { path: 'lib/screens/customer/booking_flow_screen.dart', name: 'booking_flow_screen.dart', type: 'file', description: 'Complete 5-step guided booking wizard (Branch -> Service -> Stylist -> Date/Time -> Review)', category: 'screens' },
  { path: 'lib/screens/staff/staff_dashboard_screen.dart', name: 'staff_dashboard_screen.dart', type: 'file', description: 'Staff console with branch queue, customer detail modal, and status updates', category: 'screens' },
  { path: 'lib/screens/admin/admin_dashboard_screen.dart', name: 'admin_dashboard_screen.dart', type: 'file', description: 'HQ analytics, network revenue, repeat customer rate, and branch management', category: 'screens' },
];

export const FlutterArchitectureModal: React.FC<{ isOpen: boolean; onClose: () => void }> = ({
  isOpen,
  onClose,
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedFile, setSelectedFile] = useState<FlutterFileNode>(FLUTTER_FILES[0]);
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const categories = [
    { id: 'all', label: 'All Files (34)' },
    { id: 'core', label: 'Core & Theme' },
    { id: 'models', label: 'Models' },
    { id: 'services', label: 'Services' },
    { id: 'repositories', label: 'Repositories' },
    { id: 'providers', label: 'Providers' },
    { id: 'screens', label: 'Screens' },
  ];

  const filteredFiles = selectedCategory === 'all'
    ? FLUTTER_FILES
    : FLUTTER_FILES.filter(f => f.category === selectedCategory);

  const handleCopyPath = () => {
    navigator.clipboard.writeText(selectedFile.path);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-slate-900 border border-slate-800 text-white rounded-2xl w-full max-w-4xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden">
        
        {/* Header */}
        <div className="p-4 bg-slate-950 border-b border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-rose-600/20 text-rose-400 rounded-lg border border-rose-500/30">
              <Smartphone className="w-5 h-5" />
            </div>
            <div>
              <h2 className="font-bold text-sm sm:text-base flex items-center gap-2">
                <span>Flutter + Dart Architecture Codebase</span>
                <span className="text-[10px] bg-rose-500/20 text-rose-300 px-2 py-0.5 rounded-full font-mono border border-rose-500/30">
                  Ready in /lib
                </span>
              </h2>
              <p className="text-xs text-slate-400">
                UI &rarr; Provider &rarr; Repository &rarr; Service &rarr; Firebase
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition"
          >
            ✕
          </button>
        </div>

        {/* Architecture flow banner */}
        <div className="bg-slate-900 px-4 py-2.5 border-b border-slate-800/80 flex flex-wrap items-center justify-between text-xs gap-2">
          <div className="flex items-center gap-2 text-slate-300">
            <span className="px-2 py-0.5 rounded bg-rose-950 text-rose-400 border border-rose-800 font-mono">UI Widgets</span>
            <span>&rarr;</span>
            <span className="px-2 py-0.5 rounded bg-blue-950 text-blue-400 border border-blue-800 font-mono">Provider State</span>
            <span>&rarr;</span>
            <span className="px-2 py-0.5 rounded bg-amber-950 text-amber-400 border border-amber-800 font-mono">Repositories</span>
            <span>&rarr;</span>
            <span className="px-2 py-0.5 rounded bg-emerald-950 text-emerald-400 border border-emerald-800 font-mono">Services</span>
            <span>&rarr;</span>
            <span className="px-2 py-0.5 rounded bg-purple-950 text-purple-400 border border-purple-800 font-mono">Cloud Firestore</span>
          </div>
          <div className="text-[11px] text-amber-400 font-mono">
            pubspec.yaml + 33 Dart files generated
          </div>
        </div>

        {/* Category Tabs */}
        <div className="flex overflow-x-auto border-b border-slate-800 bg-slate-950/50 px-4 py-2 gap-1.5 scrollbar-none text-xs">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`px-3 py-1.5 rounded-lg whitespace-nowrap font-medium transition ${
                selectedCategory === cat.id
                  ? 'bg-rose-600 text-white shadow'
                  : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Master-Detail Explorer */}
        <div className="flex-1 grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-slate-800 overflow-hidden">
          
          {/* File list */}
          <div className="overflow-y-auto p-3 space-y-1 max-h-72 md:max-h-full">
            {filteredFiles.map((file) => {
              const isSelected = selectedFile.path === file.path;
              return (
                <button
                  key={file.path}
                  onClick={() => setSelectedFile(file)}
                  className={`w-full text-left p-2.5 rounded-xl text-xs transition flex items-start justify-between gap-2 border ${
                    isSelected
                      ? 'bg-slate-800/90 border-rose-500/50 text-white'
                      : 'bg-slate-900/40 border-transparent hover:bg-slate-800/50 text-slate-300'
                  }`}
                >
                  <div className="flex items-start gap-2 overflow-hidden">
                    <FileCode className={`w-4 h-4 shrink-0 mt-0.5 ${isSelected ? 'text-rose-400' : 'text-slate-500'}`} />
                    <div className="overflow-hidden">
                      <div className="font-mono font-medium truncate">{file.path}</div>
                      <div className="text-[11px] text-slate-400 line-clamp-1 mt-0.5">{file.description}</div>
                    </div>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 text-slate-600 shrink-0 mt-1" />
                </button>
              );
            })}
          </div>

          {/* File detail preview */}
          <div className="p-4 bg-slate-950/40 flex flex-col justify-between overflow-y-auto">
            <div className="space-y-4">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                <div>
                  <span className="text-[11px] font-mono text-rose-400 uppercase tracking-wider">
                    {selectedFile.category.toUpperCase()} LAYER
                  </span>
                  <h3 className="font-mono text-sm font-bold text-white mt-0.5">
                    /{selectedFile.path}
                  </h3>
                </div>
                <button
                  onClick={handleCopyPath}
                  className="px-2.5 py-1 text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg flex items-center gap-1.5 transition border border-slate-700"
                >
                  {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                  <span>{copied ? 'Copied!' : 'Copy Path'}</span>
                </button>
              </div>

              <div className="bg-slate-900 p-3.5 rounded-xl border border-slate-800">
                <div className="text-xs font-semibold text-slate-300 mb-1.5 flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-rose-400" />
                  <span>Architecture Role & Responsibilities</span>
                </div>
                <p className="text-xs text-slate-300 leading-relaxed">
                  {selectedFile.description}
                </p>
              </div>

              <div className="space-y-2 text-xs text-slate-400">
                <div className="flex justify-between border-b border-slate-800/60 pb-1.5">
                  <span>Language</span>
                  <span className="text-slate-200 font-mono">Dart (Null Safe)</span>
                </div>
                <div className="flex justify-between border-b border-slate-800/60 pb-1.5">
                  <span>Target Framework</span>
                  <span className="text-slate-200 font-mono">Flutter Material 3</span>
                </div>
                <div className="flex justify-between border-b border-slate-800/60 pb-1.5">
                  <span>State Pattern</span>
                  <span className="text-slate-200 font-mono">Provider (ChangeNotifier)</span>
                </div>
                <div className="flex justify-between">
                  <span>Storage Backend</span>
                  <span className="text-slate-200 font-mono">Cloud Firestore + Auth</span>
                </div>
              </div>
            </div>

            <div className="pt-4 border-t border-slate-800 text-[11px] text-slate-500">
              This file is saved in the workspace ready for <code className="text-rose-400 font-mono">flutter run</code> or Git export.
            </div>
          </div>

        </div>

        {/* Footer */}
        <div className="p-3 bg-slate-950 border-t border-slate-800 flex items-center justify-between text-xs">
          <span className="text-slate-400">
            StyleHub Centralized Multi-Branch Architecture
          </span>
          <button
            onClick={onClose}
            className="px-4 py-1.5 bg-rose-600 hover:bg-rose-500 text-white font-medium rounded-lg transition"
          >
            Back to App Simulator
          </button>
        </div>

      </div>
    </div>
  );
};
