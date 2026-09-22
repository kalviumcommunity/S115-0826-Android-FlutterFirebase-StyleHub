import React from 'react';

interface AppCardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  hoverable?: boolean;
  padding?: 'none' | 'sm' | 'md' | 'lg';
  id?: string;
}

export const AppCard: React.FC<AppCardProps> = ({
  children,
  className = '',
  onClick,
  hoverable = false,
  padding = 'md',
  id,
}) => {
  const paddingStyles = {
    none: 'p-0',
    sm: 'p-3',
    md: 'p-4 sm:p-5',
    lg: 'p-5 sm:p-6',
  };

  return (
    <div
      id={id}
      onClick={onClick}
      className={`bg-white rounded-2xl border border-slate-100/90 shadow-sm transition-all duration-200 ${
        paddingStyles[padding]
      } ${
        hoverable ? 'hover:shadow-md hover:border-slate-200 hover:-translate-y-0.5 cursor-pointer' : ''
      } ${onClick ? 'cursor-pointer' : ''} ${className}`}
    >
      {children}
    </div>
  );
};
