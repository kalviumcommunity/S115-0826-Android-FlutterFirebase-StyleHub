import React from 'react';
import { Sparkles, AlertCircle, RefreshCw } from 'lucide-react';
import { AppButton } from './AppButton';
import { AppointmentStatus } from '../../types';

export const LoadingWidget: React.FC<{ message?: string; className?: string }> = ({
  message = 'Loading StyleHub Salon Network...',
  className = '',
}) => {
  return (
    <div className={`flex flex-col items-center justify-center py-12 px-4 text-center ${className}`}>
      <div className="relative mb-4">
        <div className="w-12 h-12 rounded-full border-3 border-rose-100 border-t-rose-600 animate-spin" />
        <Sparkles className="w-5 h-5 text-rose-500 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-pulse" />
      </div>
      <p className="text-sm font-medium text-slate-600">{message}</p>
    </div>
  );
};

export const EmptyStateWidget: React.FC<{
  icon?: React.ReactNode;
  title: string;
  description: string;
  actionText?: string;
  onAction?: () => void;
  className?: string;
}> = ({
  icon,
  title,
  description,
  actionText,
  onAction,
  className = '',
}) => {
  return (
    <div className={`flex flex-col items-center justify-center text-center p-8 bg-slate-50/70 border border-dashed border-slate-200 rounded-2xl ${className}`}>
      {icon && <div className="p-3 bg-white text-slate-400 rounded-2xl shadow-xs mb-3">{icon}</div>}
      <h4 className="text-base font-semibold text-slate-800 mb-1">{title}</h4>
      <p className="text-xs text-slate-500 max-w-xs mb-4 leading-relaxed">{description}</p>
      {actionText && onAction && (
        <AppButton size="sm" variant="primary" onClick={onAction}>
          {actionText}
        </AppButton>
      )}
    </div>
  );
};

export const AppErrorWidget: React.FC<{
  message: string;
  onRetry?: () => void;
  className?: string;
}> = ({ message, onRetry, className = '' }) => {
  return (
    <div className={`flex items-start gap-3 p-4 bg-red-50/80 border border-red-200/80 rounded-2xl text-left ${className}`}>
      <AlertCircle className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
      <div className="flex-1">
        <h5 className="text-sm font-semibold text-red-900 mb-0.5">Error Occurred</h5>
        <p className="text-xs text-red-700 leading-relaxed">{message}</p>
        {onRetry && (
          <button
            onClick={onRetry}
            className="mt-2 inline-flex items-center gap-1.5 text-xs font-semibold text-red-800 hover:text-red-900 underline"
          >
            <RefreshCw className="w-3 h-3" /> Retry Operation
          </button>
        )}
      </div>
    </div>
  );
};

export const StatusBadge: React.FC<{ status: AppointmentStatus; size?: 'sm' | 'md' }> = ({
  status,
  size = 'md',
}) => {
  const styles: Record<AppointmentStatus, { bg: string; text: string; dot: string }> = {
    Pending: {
      bg: 'bg-amber-50 border-amber-200/70',
      text: 'text-amber-800',
      dot: 'bg-amber-500',
    },
    Confirmed: {
      bg: 'bg-emerald-50 border-emerald-200/70',
      text: 'text-emerald-800',
      dot: 'bg-emerald-500',
    },
    Completed: {
      bg: 'bg-blue-50 border-blue-200/70',
      text: 'text-blue-800',
      dot: 'bg-blue-500',
    },
    Cancelled: {
      bg: 'bg-slate-100 border-slate-200',
      text: 'text-slate-600',
      dot: 'bg-slate-400',
    },
  };

  const current = styles[status] || styles.Pending;
  const sizeClass = size === 'sm' ? 'text-[10px] px-2 py-0.5 gap-1' : 'text-xs px-2.5 py-1 gap-1.5';

  return (
    <span
      className={`inline-flex items-center font-medium rounded-full border ${current.bg} ${current.text} ${sizeClass} whitespace-nowrap`}
    >
      <span className={`w-1.5 h-1.5 rounded-full ${current.dot} shrink-0`} />
      {status}
    </span>
  );
};
