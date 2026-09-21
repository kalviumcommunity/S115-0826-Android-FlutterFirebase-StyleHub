import React, { useState } from 'react';
import { Scissors, User, Building, Shield, ChevronDown, Sparkles, LogOut, Check } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { UserRole } from '../../types';

interface NavbarProps {
  onOpenBooking: () => void;
  onNavigateHome: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onOpenBooking, onNavigateHome }) => {
  const { currentUser, role, logout, isAuthenticated } = useAuth();
  const [showRoleMenu, setShowRoleMenu] = useState(false);

  const roleLabels: Record<UserRole, { label: string; color: string; icon: React.ReactNode }> = {
    customer: { label: 'Customer View', color: 'bg-rose-50 text-rose-700 border-rose-200', icon: <User className="w-3 h-3" /> },
    staff: { label: 'Staff Console', color: 'bg-blue-50 text-blue-700 border-blue-200', icon: <Building className="w-3 h-3" /> },
    admin: { label: 'HQ Admin', color: 'bg-amber-50 text-amber-700 border-amber-200', icon: <Shield className="w-3 h-3" /> },
  };

  const currentBadge = roleLabels[role];

  return (
    <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-100 shadow-2xs">
      <div className="max-w-4xl mx-auto px-4 py-2.5 flex items-center justify-between">
        
        {/* Brand Logo */}
        <button
          onClick={onNavigateHome}
          className="flex items-center gap-2 group text-left focus:outline-none"
        >
          <div className="w-9 h-9 rounded-xl bg-rose-600 text-white flex items-center justify-center shadow-xs group-hover:scale-105 transition">
            <Scissors className="w-5 h-5" />
          </div>
          <div>
            <span className="text-base font-extrabold text-slate-900 tracking-tight flex items-center gap-1">
              StyleHub
              <span className="w-1.5 h-1.5 rounded-full bg-rose-600 inline-block" />
            </span>
            <span className="text-[10px] text-slate-400 block -mt-1 font-medium tracking-wide">
              Central Salon Network
            </span>
          </div>
        </button>

        {/* Role Switcher & Actions */}
        <div className="flex items-center gap-2 sm:gap-3">
          
          {/* Quick Role Switcher (Crucial for QA and instant multi-role verification) */}
          <div className="relative">
            <button
              onClick={() => setShowRoleMenu(!showRoleMenu)}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold border transition ${currentBadge.color} hover:brightness-95`}
            >
              {currentBadge.icon}
              <span className="hidden xs:inline">{currentBadge.label}</span>
              <ChevronDown className="w-3 h-3" />
            </button>

            {/* Dropdown */}
            {showRoleMenu && (
              <div className="absolute right-0 mt-2 w-52 bg-white rounded-2xl shadow-xl border border-slate-100 p-2 z-50 animate-in fade-in slide-in-from-top-2">
                <div className="px-2 py-1.5 text-[10px] font-bold text-slate-400 uppercase tracking-wider border-b border-slate-100">
                  Account Options
                </div>

                {isAuthenticated && (
                  <div className="pt-1">
                    <button
                      onClick={() => {
                        logout();
                        setShowRoleMenu(false);
                      }}
                      className="w-full flex items-center gap-2 p-2 rounded-xl text-xs font-semibold text-red-600 hover:bg-red-50 transition"
                    >
                      <LogOut className="w-3.5 h-3.5" />
                      <span>Sign Out</span>
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Quick Book Call To Action for Customers */}
          {role === 'customer' && (
            <button
              onClick={onOpenBooking}
              className="bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold px-3 py-1.5 rounded-xl shadow-xs flex items-center gap-1.5 transition active:scale-95"
            >
              <Sparkles className="w-3.5 h-3.5" />
              <span>Book</span>
            </button>
          )}

        </div>
      </div>
    </header>
  );
};
