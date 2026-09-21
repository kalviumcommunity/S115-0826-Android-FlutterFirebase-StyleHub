import React, { useState } from 'react';
import { 
  Search, 
  Sparkles, 
  MapPin, 
  Calendar, 
  ArrowRight, 
  Star, 
  Clock, 
  Compass, 
  ShieldCheck,
  ChevronRight,
  Filter
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { dataService } from '../../services/dataService';
import { Branch, SalonService, Stylist, Appointment } from '../../types';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { BranchCard } from '../cards/BranchCard';
import { ServiceCard } from '../cards/ServiceCard';
import { StylistCard } from '../cards/StylistCard';
import { StatusBadge } from '../common/FeedbackWidgets';

interface CustomerHomeScreenProps {
  onStartBooking: (branchId?: string, serviceId?: string, stylistId?: string) => void;
  onViewAllAppointments: () => void;
  onViewHistory: () => void;
}

export const CustomerHomeScreen: React.FC<CustomerHomeScreenProps> = ({
  onStartBooking,
  onViewAllAppointments,
  onViewHistory,
}) => {
  const { currentUser } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const branches = dataService.getBranches().filter(b => b.active);
  const services = dataService.getServices().filter(s => s.active);
  const stylists = dataService.getStylists().filter(s => s.active);
  
  // Customer's upcoming appointments
  const customerApts = currentUser ? dataService.getCustomerAppointments(currentUser.uid) : [];
  const nextAppointment = customerApts.find(a => a.status === 'Confirmed' || a.status === 'Pending');

  // Customer cross-branch network profile
  const networkProfile = currentUser ? dataService.getCustomerNetworkProfile(currentUser.uid) : null;

  // Filtered lists based on search
  const filteredBranches = branches.filter(b => 
    b.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.city.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.address.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filteredServices = services.filter(s => {
    const matchesQuery = s.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      s.category.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCat = selectedCategory === 'All' || s.category === selectedCategory;
    return matchesQuery && matchesCat;
  });

  const categories = ['All', 'Hair', 'Skin & Facial', 'Spa & Wellness', 'Nails', 'Grooming'];

  return (
    <div className="space-y-5 pb-6">
      
      {/* Top Header & Greeting */}
      <div className="flex items-center justify-between">
        <div>
          <span className="text-[11px] font-bold text-rose-600 uppercase tracking-wider flex items-center gap-1">
            <Sparkles className="w-3 h-3" /> StyleHub Network
          </span>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight">
            Hello, {currentUser?.name ? currentUser.name.split(' ')[0] : 'Guest'}
          </h2>
          <p className="text-xs text-slate-500">Welcome to your centralized salon sanctuary</p>
        </div>

        <div className="relative">
          <img
            src={currentUser?.profileImage || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'}
            alt="Profile"
            className="w-11 h-11 rounded-full object-cover border-2 border-rose-500/20 shadow-xs"
          />
          <span className="absolute bottom-0 right-0 w-3 h-3 rounded-full bg-emerald-500 border-2 border-white" />
        </div>
      </div>

      {/* Global Customer Pass Banner (Addressing Project Problem Statement) */}
      <div className="p-4 rounded-3xl bg-gradient-to-br from-slate-900 via-slate-800 to-rose-950 text-white shadow-md relative overflow-hidden">
        <div className="absolute right-0 top-0 translate-x-4 -translate-y-4 w-32 h-32 bg-rose-500/10 rounded-full blur-2xl pointer-events-none" />
        
        <div className="flex items-start justify-between">
          <div>
            <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-2.5 py-0.5 rounded-full text-[10px] font-semibold text-rose-300 w-fit mb-2">
              <ShieldCheck className="w-3 h-3" />
              <span>Universal Salon Pass</span>
            </div>
            <h3 className="text-base font-bold text-white tracking-wide">
              {networkProfile?.branchesVisited.length ? `${networkProfile.branchesVisited.length} Outlets Visited` : 'Multi-Branch Freedom'}
            </h3>
            <p className="text-xs text-slate-300 mt-0.5 max-w-[240px]">
              Your service history, favorite stylists, and VIP preferences are shared seamlessly across all branches.
            </p>
          </div>

          <div className="text-right">
            <span className="text-[10px] text-slate-400 block font-mono">UID: {currentUser?.uid || 'GUEST'}</span>
            <button
              onClick={onViewHistory}
              className="mt-3 text-xs text-rose-400 hover:text-rose-300 font-semibold flex items-center gap-1 ml-auto"
            >
              History <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        {/* Recently visited branch pills */}
        {networkProfile && networkProfile.branchesVisited.length > 0 && (
          <div className="mt-3 pt-3 border-t border-white/10 flex items-center gap-1.5 overflow-x-auto text-[10px]">
            <span className="text-slate-400 shrink-0">Recognized at:</span>
            {networkProfile.branchesVisited.map((branch, i) => (
              <span
                key={i}
                className="bg-white/15 px-2 py-0.5 rounded-md text-white whitespace-nowrap"
              >
                {branch}
              </span>
            ))}
          </div>
        )}
      </div>

      {/* Next Upcoming Appointment (if any) */}
      {nextAppointment && (
        <div className="space-y-1.5">
          <div className="flex items-center justify-between text-xs px-1">
            <span className="font-bold text-slate-700 uppercase tracking-wider text-[11px]">
              Upcoming Appointment
            </span>
            <button
              onClick={onViewAllAppointments}
              className="text-rose-600 font-semibold text-xs hover:underline flex items-center gap-0.5"
            >
              View All <ChevronRight className="w-3 h-3" />
            </button>
          </div>

          <AppCard padding="sm" className="bg-rose-50/40 border-rose-200/80 shadow-xs">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-1.5 text-xs font-bold text-slate-800">
                <MapPin className="w-3.5 h-3.5 text-rose-500" />
                {nextAppointment.branchName}
              </div>
              <StatusBadge status={nextAppointment.status} size="sm" />
            </div>

            <div className="flex items-center justify-between text-xs">
              <div>
                <p className="font-bold text-slate-900">{nextAppointment.serviceName}</p>
                <p className="text-slate-500 text-[11px]">With {nextAppointment.stylistName}</p>
              </div>
              <div className="text-right">
                <span className="font-bold text-slate-800 flex items-center gap-1">
                  <Calendar className="w-3 h-3 text-slate-400" />
                  {nextAppointment.appointmentDate}
                </span>
                <span className="text-slate-500 text-[11px] block">{nextAppointment.startTime}</span>
              </div>
            </div>
          </AppCard>
        </div>
      )}

      {/* Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="Search branches, haircuts, facials, or stylists..."
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-2xl text-xs text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-rose-500/20 focus:border-rose-500 shadow-2xs"
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-slate-600"
          >
            Clear
          </button>
        )}
      </div>

      {/* Quick Book Call To Action */}
      <div className="flex items-center justify-between p-4 bg-rose-600 text-white rounded-3xl shadow-sm">
        <div>
          <h4 className="font-bold text-sm">Need a Fresh Style?</h4>
          <p className="text-xs text-rose-100">Select branch, service, and stylist in seconds</p>
        </div>
        <AppButton
          variant="secondary"
          size="sm"
          onClick={() => onStartBooking()}
          rightIcon={<ArrowRight className="w-3.5 h-3.5" />}
        >
          Quick Book
        </AppButton>
      </div>

      {/* Available Branches Section */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">StyleHub Branches</h3>
            <p className="text-[11px] text-slate-500">Cross-branch appointments available</p>
          </div>
          <span className="text-xs font-semibold text-slate-400">{filteredBranches.length} Outlets</span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
          {filteredBranches.map(branch => (
            <BranchCard
              key={branch.branchId}
              branch={branch}
              onSelect={() => onStartBooking(branch.branchId)}
            />
          ))}
        </div>
      </div>

      {/* Services Section with Category Filters */}
      <div className="space-y-3 pt-2">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Popular Services</h3>
            <p className="text-[11px] text-slate-500">Premium hair, skin, and spa treatments</p>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex gap-1.5 overflow-x-auto pb-1 -mx-1 px-1">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-all ${
                selectedCategory === cat
                  ? 'bg-slate-900 text-white'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {filteredServices.map(service => (
            <ServiceCard
              key={service.serviceId}
              service={service}
              onSelect={() => onStartBooking(undefined, service.serviceId)}
            />
          ))}
        </div>
      </div>

      {/* Recommended Stylists Section */}
      <div className="space-y-3 pt-2">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Master Stylists</h3>
            <p className="text-[11px] text-slate-500">Top rated across Pune outlets</p>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {stylists.slice(0, 4).map(stylist => (
            <StylistCard
              key={stylist.stylistId}
              stylist={stylist}
              onSelect={() => onStartBooking(stylist.branchId, undefined, stylist.stylistId)}
            />
          ))}
        </div>
      </div>

    </div>
  );
};
