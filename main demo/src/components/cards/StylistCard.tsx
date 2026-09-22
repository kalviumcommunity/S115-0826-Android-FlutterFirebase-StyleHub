import React from 'react';
import { Star, Award, MapPin } from 'lucide-react';
import { Stylist } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';

interface StylistCardProps {
  stylist: Stylist;
  onSelect?: (stylist: Stylist) => void;
  selected?: boolean;
  compact?: boolean;
}

export const StylistCard: React.FC<StylistCardProps> = ({
  stylist,
  onSelect,
  selected = false,
  compact = false,
}) => {
  if (compact) {
    return (
      <AppCard
        hoverable
        padding="sm"
        onClick={() => onSelect?.(stylist)}
        className={`flex items-center justify-between border-2 transition-all ${
          selected ? 'border-rose-600 bg-rose-50/30' : 'border-slate-100 hover:border-slate-200'
        }`}
      >
        <div className="flex items-center gap-3 min-w-0">
          <img
            src={stylist.profileImage}
            alt={stylist.name}
            className="w-12 h-12 rounded-full object-cover shrink-0 border border-slate-200"
          />
          <div className="min-w-0">
            <h4 className="text-sm font-bold text-slate-800 truncate">{stylist.name}</h4>
            <p className="text-xs text-rose-600 font-medium truncate">{stylist.specialization}</p>
            <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-0.5">
              <span className="flex items-center gap-0.5 text-amber-600 font-semibold">
                <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                {stylist.rating}
              </span>
              <span>•</span>
              <span>{stylist.experience}</span>
            </div>
          </div>
        </div>

        {onSelect && (
          <AppButton
            size="sm"
            variant={selected ? 'primary' : 'outline'}
            className="shrink-0 ml-2"
          >
            {selected ? 'Selected' : 'Select'}
          </AppButton>
        )}
      </AppCard>
    );
  }

  return (
    <AppCard
      padding="none"
      className={`overflow-hidden flex flex-col justify-between border-2 transition-all ${
        selected ? 'border-rose-600 ring-2 ring-rose-100' : 'border-slate-100 hover:border-slate-200'
      }`}
    >
      <div className="p-4 flex items-start gap-3">
        <div className="relative shrink-0">
          <img
            src={stylist.profileImage}
            alt={stylist.name}
            className="w-16 h-16 rounded-full object-cover border-2 border-white shadow-xs"
          />
          <span className="absolute -bottom-1 -right-1 bg-amber-50 border border-amber-200 text-amber-800 text-[10px] font-bold px-1.5 py-0.5 rounded-full flex items-center gap-0.5">
            <Star className="w-2.5 h-2.5 fill-amber-400 text-amber-500" />
            {stylist.rating}
          </span>
        </div>

        <div className="flex-1 min-w-0">
          <h4 className="text-sm font-bold text-slate-900 truncate">{stylist.name}</h4>
          <p className="text-xs text-rose-600 font-medium truncate">{stylist.specialization}</p>
          
          {stylist.branchName && (
            <p className="text-[11px] text-slate-500 flex items-center gap-1 mt-1 truncate">
              <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
              {stylist.branchName}
            </p>
          )}

          <div className="flex items-center gap-1 text-[11px] text-slate-500 mt-1">
            <Award className="w-3 h-3 text-slate-400 shrink-0" />
            <span>{stylist.experience} experience</span>
          </div>
        </div>
      </div>

      <div className="px-4 pb-4 space-y-3">
        <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">{stylist.bio}</p>

        <div className="pt-2 border-t border-slate-100 flex items-center justify-between">
          <span className="text-[11px] text-slate-400">
            {stylist.availability.length} available slots
          </span>
          {onSelect && (
            <AppButton
              size="sm"
              variant={selected ? 'primary' : 'outline'}
              onClick={() => onSelect(stylist)}
            >
              {selected ? 'Selected' : 'Book Stylist'}
            </AppButton>
          )}
        </div>
      </div>
    </AppCard>
  );
};
