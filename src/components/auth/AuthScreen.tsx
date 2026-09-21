import React, { useState } from 'react';
import { Sparkles, Scissors, User, Lock, Mail, Phone, ArrowRight, ShieldCheck } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { UserRole } from '../../types';

interface AuthScreenProps {
  onSuccess?: () => void;
}

export const AuthScreen: React.FC<AuthScreenProps> = ({ onSuccess }) => {
  const { login, register } = useAuth();
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [role, setRole] = useState<UserRole>('customer');
  const [isLoading, setIsLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg('');
    setIsLoading(true);

    try {
      if (mode === 'login') {
        if (!email) {
          setErrorMsg('Please enter your registered email address.');
          setIsLoading(false);
          return;
        }
        await login(email, role);
      } else {
        if (!name || !email || !phone) {
          setErrorMsg('Please fill in all registration fields.');
          setIsLoading(false);
          return;
        }
        await register(name, email, phone, role);
      }
      onSuccess?.();
    } catch {
      setErrorMsg('Authentication error. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-3xl p-6 sm:p-8 shadow-xl border border-slate-100 space-y-6">
        
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-rose-600 text-white mx-auto flex items-center justify-center shadow-md shadow-rose-200">
            <Scissors className="w-6 h-6" />
          </div>
          <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">
            StyleHub Central
          </h2>
          <p className="text-xs text-slate-500 max-w-xs mx-auto">
            Multi-branch salon network with a single unified customer profile
          </p>
        </div>

        {/* Tab switch: Sign In vs Sign Up */}
        <div className="flex rounded-xl bg-slate-100 p-1 text-xs font-semibold">
          <button
            onClick={() => setMode('login')}
            className={`flex-1 py-2 rounded-lg transition ${
              mode === 'login' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
            }`}
          >
            Sign In
          </button>
          <button
            onClick={() => setMode('register')}
            className={`flex-1 py-2 rounded-lg transition ${
              mode === 'register' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
            }`}
          >
            Register Account
          </button>
        </div>

        {errorMsg && (
          <p className="text-xs text-red-600 font-medium text-center bg-red-50 p-2.5 rounded-xl border border-red-200">
            {errorMsg}
          </p>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-3.5">
          {mode === 'register' && (
            <AppTextField
              label="Full Name"
              placeholder="E.g., Ananya Sharma"
              value={name}
              onChange={e => setName(e.target.value)}
              leftIcon={<User className="w-4 h-4" />}
              required
            />
          )}

          <AppTextField
            label="Email Address"
            type="email"
            placeholder="name@example.com"
            value={email}
            onChange={e => setEmail(e.target.value)}
            leftIcon={<Mail className="w-4 h-4" />}
            required
          />

          {mode === 'register' && (
            <AppTextField
              label="Phone Number"
              placeholder="+91 98765 43210"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              leftIcon={<Phone className="w-4 h-4" />}
              required
            />
          )}

          <AppTextField
            label="Password"
            type="password"
            placeholder="••••••••"
            value={password}
            onChange={e => setPassword(e.target.value)}
            leftIcon={<Lock className="w-4 h-4" />}
          />

          <AppButton
            type="submit"
            variant="primary"
            fullWidth
            isLoading={isLoading}
            rightIcon={<ArrowRight className="w-4 h-4" />}
          >
            {mode === 'login' ? 'Sign In to StyleHub' : 'Create Global Account'}
          </AppButton>
        </form>

        <p className="text-[11px] text-center text-slate-400">
          By continuing, you agree to StyleHub&apos;s unified multi-branch terms and privacy policy.
        </p>

      </div>
    </div>
  );
};
