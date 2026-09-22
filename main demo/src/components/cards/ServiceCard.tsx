import React from 'react';
import { Clock, Tag, Sparkles } from 'lucide-react';
import { SalonService } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';

interface ServiceCardProps {
  service: SalonService;
  onSelect?: (service: SalonService) => void;
  selected?: boolean;
  compact?: boolean;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({
  service,
  onSelect,
  selected = false,
  compact = false,
}) => {
  if (compact) {
    return (
      <AppCard
        hoverable
        padding="sm"
        onClick={() => onSelect?.(service)}
        className={`flex items-center justify-between border-2 transition-all ${
          selected ? 'border-rose-600 bg-rose-50/30' : 'border-slate-100 hover:border-slate-200'
        }`}
      >
        <div className="flex items-center gap-3 min-w-0">
          <img
            src={service.image}
            alt={service.name}
            className="w-12 h-12 rounded-xl object-cover shrink-0"
          />
          <div className="min-w-0">
            <h4 className="text-sm font-bold text-slate-800 truncate">{service.name}</h4>
            <div className="flex items-center gap-2 text-xs text-slate-500 mt-0.5">
              <span className="flex items-center gap-1">
                <Clock className="w-3 h-3 text-slate-400" />
                {service.duration} mins
              </span>
              <span>•</span>
              <span className="font-semibold text-rose-600">₹{service.price}</span>
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
      <div className="relative h-36 w-full overflow-hidden bg-slate-100">
        <img
          src={service.image}
          alt={service.name}
          className="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
        />
        <div className="absolute top-2.5 left-2.5">
          <span className="px-2 py-0.5 rounded-md bg-black/60 backdrop-blur-md text-[10px] font-semibold text-white uppercase tracking-wider flex items-center gap-1">
            <Tag className="w-2.5 h-2.5 text-rose-400" />
            {service.category}
          </span>
        </div>
        <div className="absolute bottom-2.5 right-2.5 bg-rose-600 text-white font-bold text-xs px-2.5 py-1 rounded-lg shadow-sm">
          ₹{service.price}
        </div>
      </div>

      <div className="p-4 flex-1 flex flex-col justify-between space-y-3">
        <div>
          <h4 className="text-sm font-bold text-slate-800 mb-1">{service.name}</h4>
          <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">{service.description}</p>
        </div>

        <div className="pt-2 border-t border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-1 text-xs text-slate-500">
            <Clock className="w-3.5 h-3.5 text-slate-400" />
            <span>{service.duration} mins</span>
          </div>

          {onSelect && (
            <AppButton
              size="sm"
              variant={selected ? 'primary' : 'outline'}
              onClick={() => onSelect(service)}
              leftIcon={selected ? <Sparkles className="w-3 h-3" /> : undefined}
            >
              {selected ? 'Selected' : 'Book Service'}
            </AppButton>
          )}
        </div>
      </div>
    </AppCard>
  );
};
