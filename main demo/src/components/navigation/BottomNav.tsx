import React from 'react';
import { Home, Calendar, History, User, Building, BarChart3 } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export type CustomerTab = 'home' | 'appointments' | 'history' | 'profile';

interface BottomNavProps {
  activeCustomerTab: CustomerTab;
  onSelectCustomerTab: (tab: CustomerTab) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeCustomerTab,
  onSelectCustomerTab,
}) => {
  const { role } = useAuth();

  // Bottom navigation is focused on customer flow
  if (role !== 'customer') return null;

  const tabs: { id: CustomerTab; label: string; icon: React.ReactNode }[] = [
    { id: 'home', label: 'Explore', icon: <Home className="w-5 h-5" /> },
    { id: 'appointments', label: 'Bookings', icon: <Calendar className="w-5 h-5" /> },
    { id: 'history', label: 'Network History', icon: <History className="w-5 h-5" /> },
    { id: 'profile', label: 'Profile', icon: <User className="w-5 h-5" /> },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-slate-200/80 max-w-lg mx-auto shadow-lg">
      <div className="flex items-center justify-around py-1.5 px-2">
        {tabs.map(tab => {
          const isActive = activeCustomerTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onSelectCustomerTab(tab.id)}
              className={`flex flex-col items-center justify-center py-1.5 px-3 rounded-2xl transition-all ${
                isActive
                  ? 'text-rose-600 font-bold'
                  : 'text-slate-400 hover:text-slate-600 font-medium'
              }`}
            >
              <div className={`p-1 rounded-xl transition ${isActive ? 'bg-rose-50' : ''}`}>
                {tab.icon}
              </div>
              <span className="text-[10px] mt-0.5 tracking-tight">{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
