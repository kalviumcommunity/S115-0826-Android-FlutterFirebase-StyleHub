import React, { useState } from 'react';
import { 
  User, 
  Mail, 
  Phone, 
  Shield, 
  Edit3, 
  LogOut, 
  Check, 
  Copy, 
  Sparkles, 
  RefreshCw,
  Building,
  Star
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { dataService } from '../../services/dataService';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';

interface CustomerProfileScreenProps {
  onRoleSwitched: () => void;
}

export const CustomerProfileScreen: React.FC<CustomerProfileScreenProps> = ({
  onRoleSwitched,
}) => {
  const { currentUser, updateProfile, logout, switchRole } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(currentUser?.name || '');
  const [phone, setPhone] = useState(currentUser?.phone || '');
  const [copiedUid, setCopiedUid] = useState(false);
  const [resetSuccess, setResetSuccess] = useState(false);

  const networkProfile = currentUser 
    ? dataService.getCustomerNetworkProfile(currentUser.uid)
    : null;

  const handleSave = () => {
    updateProfile({ name, phone });
    setIsEditing(false);
  };

  const copyUid = () => {
    if (!currentUser) return;
    navigator.clipboard.writeText(currentUser.uid);
    setCopiedUid(true);
    setTimeout(() => setCopiedUid(false), 2000);
  };

  const handleResetData = () => {
    if (window.confirm('Reset all branches, appointments, and stylists to default demo data?')) {
      dataService.resetToDemoData();
      setResetSuccess(true);
      setTimeout(() => setResetSuccess(false), 2500);
    }
  };

  return (
    <div className="space-y-5 pb-6">
      
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold text-slate-900">My Profile</h2>
        <p className="text-xs text-slate-500">Universal StyleHub customer account</p>
      </div>

      {/* Main Avatar & Profile Summary Card */}
      <AppCard padding="md" className="space-y-4">
        <div className="flex items-center gap-4">
          <div className="relative">
            <img
              src={currentUser?.profileImage || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80'}
              alt="Avatar"
              className="w-16 h-16 rounded-full object-cover border-2 border-rose-500/20 shadow-xs"
            />
            <span className="absolute bottom-0 right-0 p-1 rounded-full bg-rose-600 text-white text-[10px]">
              <Sparkles className="w-2.5 h-2.5" />
            </span>
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <h3 className="text-base font-bold text-slate-900 truncate">
                {currentUser?.name}
              </h3>
              <span className="text-[10px] bg-rose-50 text-rose-700 font-bold px-2 py-0.5 rounded-full uppercase border border-rose-200">
                VIP Client
              </span>
            </div>
            <p className="text-xs text-slate-500 truncate mt-0.5">{currentUser?.email}</p>
            <p className="text-xs text-slate-500 truncate">{currentUser?.phone}</p>
          </div>

          <button
            onClick={() => setIsEditing(!isEditing)}
            className="p-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-600 transition shrink-0"
          >
            <Edit3 className="w-4 h-4" />
          </button>
        </div>

        {/* Global UID display (Highlighting core requirement) */}
        <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/80 flex items-center justify-between text-xs">
          <div>
            <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider block">
              Global Unique Identifier (UID)
            </span>
            <span className="font-mono font-bold text-slate-800">{currentUser?.uid}</span>
          </div>
          <button
            onClick={copyUid}
            className="flex items-center gap-1 text-xs text-rose-600 hover:text-rose-700 font-semibold px-2 py-1 rounded-lg hover:bg-rose-50 transition"
          >
            {copiedUid ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
            <span>{copiedUid ? 'Copied' : 'Copy'}</span>
          </button>
        </div>

        {/* Edit mode form */}
        {isEditing && (
          <div className="pt-3 border-t border-slate-100 space-y-3 animate-in fade-in">
            <AppTextField
              label="Full Name"
              value={name}
              onChange={e => setName(e.target.value)}
            />
            <AppTextField
              label="Phone Number"
              value={phone}
              onChange={e => setPhone(e.target.value)}
            />
            <div className="flex justify-end gap-2 pt-1">
              <AppButton size="sm" variant="outline" onClick={() => setIsEditing(false)}>
                Cancel
              </AppButton>
              <AppButton size="sm" variant="primary" onClick={handleSave}>
                Save Changes
              </AppButton>
            </div>
          </div>
        )}
      </AppCard>

      {/* Network Loyalty Status */}
      <AppCard padding="md" className="space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Shield className="w-4 h-4 text-rose-600" />
            <h4 className="text-sm font-bold text-slate-900">StyleHub Network Benefits</h4>
          </div>
          <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
            Active
          </span>
        </div>

        <ul className="text-xs text-slate-600 space-y-2">
          <li className="flex items-center gap-2">
            <Check className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
            <span>Unified booking history visible at any branch in the city</span>
          </li>
          <li className="flex items-center gap-2">
            <Check className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
            <span>Stylist preference notes automatically shared across outlets</span>
          </li>
          <li className="flex items-center gap-2">
            <Check className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
            <span>Priority booking access during weekend rush hours</span>
          </li>
        </ul>
      </AppCard>

      {/* Role Switcher for Seamless Testing */}
      <AppCard padding="md" className="space-y-3 border-rose-100 bg-rose-50/20">
        <div>
          <span className="text-[10px] font-bold text-rose-600 uppercase tracking-wider">
            QA Role Simulator
          </span>
          <h4 className="text-sm font-bold text-slate-900">Switch Application Role</h4>
          <p className="text-xs text-slate-500 mt-0.5">
            Switch instantly between Customer, Salon Staff, and Network Admin roles.
          </p>
        </div>

        <div className="grid grid-cols-3 gap-2">
          <button
            onClick={() => {
              switchRole('customer');
              onRoleSwitched();
            }}
            className="p-2.5 rounded-xl border border-rose-600 bg-white text-rose-700 text-xs font-bold shadow-xs flex flex-col items-center gap-1"
          >
            <User className="w-4 h-4" />
            <span>Customer</span>
          </button>

          <button
            onClick={() => {
              switchRole('staff');
              onRoleSwitched();
            }}
            className="p-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs font-bold shadow-xs flex flex-col items-center gap-1"
          >
            <Building className="w-4 h-4 text-slate-500" />
            <span>Salon Staff</span>
          </button>

          <button
            onClick={() => {
              switchRole('admin');
              onRoleSwitched();
            }}
            className="p-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs font-bold shadow-xs flex flex-col items-center gap-1"
          >
            <Shield className="w-4 h-4 text-slate-500" />
            <span>Admin</span>
          </button>
        </div>
      </AppCard>

      {/* QA Reset Demo Data */}
      <div className="flex items-center justify-between p-3 rounded-2xl bg-slate-100 text-xs">
        <div>
          <span className="font-semibold text-slate-700 block">Reset Demo Database</span>
          <span className="text-[11px] text-slate-500">Restore default branches & bookings</span>
        </div>
        <AppButton
          size="sm"
          variant="outline"
          onClick={handleResetData}
          leftIcon={<RefreshCw className="w-3 h-3" />}
        >
          {resetSuccess ? 'Reset Complete!' : 'Reset Data'}
        </AppButton>
      </div>

      {/* Logout */}
      <AppButton
        variant="danger"
        fullWidth
        onClick={logout}
        leftIcon={<LogOut className="w-4 h-4" />}
      >
        Sign Out of StyleHub
      </AppButton>

    </div>
  );
};
