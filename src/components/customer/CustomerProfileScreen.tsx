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
  Building,
  Star
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';

interface CustomerProfileScreenProps {
  onRoleSwitched: () => void;
}

export const CustomerProfileScreen: React.FC<CustomerProfileScreenProps> = ({
  onRoleSwitched,
}) => {
  const { currentUser, updateProfile, logout } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(currentUser?.name || '');
  const [phone, setPhone] = useState(currentUser?.phone || '');
  const [copiedUid, setCopiedUid] = useState(false);

  const handleSave = async () => {
    try {
      await updateProfile({ name, phone });
      setIsEditing(false);
    } catch (e) {
      console.error(e);
    }
  };

  const copyUid = () => {
    if (!currentUser) return;
    navigator.clipboard.writeText(currentUser.uid);
    setCopiedUid(true);
    setTimeout(() => setCopiedUid(false), 2000);
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

