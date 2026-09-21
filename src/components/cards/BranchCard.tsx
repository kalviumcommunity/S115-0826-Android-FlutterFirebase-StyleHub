import React from 'react';
import { MapPin, Phone, Clock, Star, ChevronRight } from 'lucide-react';
import { Branch } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';

interface BranchCardProps {
  branch: Branch;
  onSelect?: (branch: Branch) => void;
  onViewDetails?: (branch: Branch) => void;
  compact?: boolean;
}

export const BranchCard: React.FC<BranchCardProps> = ({
  branch,
  onSelect,
  onViewDetails,
  compact = false,
}) => {
  if (compact) {
    return (
      <AppCard
        hoverable
        padding="none"
        onClick={() => (onSelect ? onSelect(branch) : onViewDetails?.(branch))}
        className="overflow-hidden flex items-center gap-3 p-2.5"
      >
        <img
          src={branch.image}
          alt={branch.name}
          className="w-16 h-16 rounded-xl object-cover shrink-0"
        />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1 text-xs font-semibold text-amber-600 mb-0.5">
            <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-500" />
            <span>{branch.rating}</span>
            <span className="text-slate-400 font-normal">({branch.totalReviews})</span>
          </div>
          <h4 className="text-sm font-bold text-slate-800 truncate">{branch.name}</h4>
          <p className="text-xs text-slate-500 truncate flex items-center gap-1 mt-0.5">
            <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
            {branch.city}
          </p>
        </div>
        <ChevronRight className="w-4 h-4 text-slate-400 mr-1 shrink-0" />
      </AppCard>
    );
  }

  return (
    <AppCard padding="none" className="overflow-hidden flex flex-col group">
      <div className="relative h-40 w-full overflow-hidden bg-slate-100">
        <img
          src={branch.image}
          alt={branch.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
        <div className="absolute bottom-2.5 left-3 right-3 flex items-end justify-between text-white">
          <div>
            <span className="inline-block px-2 py-0.5 rounded-md bg-white/20 backdrop-blur-md text-[10px] font-semibold uppercase tracking-wider mb-1">
              {branch.city} Outlet
            </span>
            <h3 className="text-base font-bold text-white drop-shadow-xs">{branch.name}</h3>
          </div>
          <div className="flex items-center gap-1 bg-black/50 backdrop-blur-md px-2 py-1 rounded-lg text-xs font-bold text-amber-300">
            <Star className="w-3.5 h-3.5 fill-amber-300 text-amber-400" />
            <span>{branch.rating}</span>
          </div>
        </div>
      </div>

      <div className="p-4 flex-1 flex flex-col justify-between space-y-3">
        <div className="space-y-2 text-xs text-slate-600">
          <p className="line-clamp-2 text-slate-500">{branch.description}</p>
          <div className="flex items-center gap-2 text-slate-600">
            <MapPin className="w-3.5 h-3.5 text-rose-500 shrink-0" />
            <span className="truncate">{branch.address}</span>
          </div>
          <div className="flex items-center justify-between text-slate-500">
            <div className="flex items-center gap-1.5">
              <Clock className="w-3.5 h-3.5 text-slate-400" />
              <span>{branch.openingHours}</span>
            </div>
            <div className="flex items-center gap-1">
              <Phone className="w-3.5 h-3.5 text-slate-400" />
              <span>{branch.phone}</span>
            </div>
          </div>
        </div>

        <div className="pt-2 border-t border-slate-100 flex items-center gap-2">
          {onViewDetails && (
            <AppButton
              variant="outline"
              size="sm"
              className="flex-1"
              onClick={() => onViewDetails(branch)}
            >
              Details
            </AppButton>
          )}
          {onSelect && (
            <AppButton
              variant="primary"
              size="sm"
              className="flex-1"
              onClick={() => onSelect(branch)}
            >
              Book Outlet
            </AppButton>
          )}
        </div>
      </div>
    </AppCard>
  );
};
