export type UserRole = 'customer' | 'staff' | 'admin';
export type ServiceCategory = 'Hair' | 'Skin & Facial' | 'Spa & Wellness' | 'Nails' | 'Grooming';

export interface UserProfile {
  uid: string;
  name: string;
  email: string;
  phone: string;
  role: UserRole;
  branchId?: string;
  assignedBranchId?: string;
  profileImage?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Branch {
  branchId: string;
  name: string;
  address: string;
  city: string;
  phone: string;
  openingHours: string;
  description: string;
  image: string;
  active: boolean;
  rating: number;
  totalReviews: number;
  createdAt?: string;
}

export interface Stylist {
  stylistId: string;
  name: string;
  profileImage: string;
  branchId: string;
  branchName?: string;
  bio: string;
  experience: string;
  specialization: string;
  services?: string[]; // service names or IDs
  availability: string[]; // e.g. ["10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "04:00 PM", "05:00 PM"]
  active: boolean;
  rating: number;
  totalReviews?: number;
  createdAt?: string;
}

export interface SalonService {
  serviceId: string;
  name: string;
  description: string;
  category: ServiceCategory;
  price: number;
  duration: number; // in minutes
  image: string;
  branchAvailability?: string[]; // 'all' or specific branchIds
  active: boolean;
  createdAt?: string;
}

export type AppointmentStatus = 'Pending' | 'Confirmed' | 'Completed' | 'Cancelled';

export interface Appointment {
  appointmentId: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  branchId: string;
  branchName: string;
  stylistId: string;
  stylistName: string;
  serviceId: string;
  serviceName: string;
  servicePrice: number;
  appointmentDate: string; // YYYY-MM-DD
  startTime: string; // e.g. "11:00 AM"
  endTime: string; // e.g. "12:00 PM"
  status: AppointmentStatus;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CustomerNetworkInsight {
  customerId: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
  totalBookings: number;
  completedBookings: number;
  branchesVisited: string[];
  stylistsUsed: string[];
  favoriteService: string;
  isRepeatCustomer: boolean;
  isCrossBranchCustomer: boolean;
  firstVisitDate: string;
  lastVisitDate: string;
  totalSpent: number;
}

export interface NetworkAnalytics {
  totalCustomers: number;
  totalBranches: number;
  totalStylists: number;
  totalServices: number;
  totalBookings: number;
  completedBookings: number;
  cancelledBookings: number;
  repeatCustomersCount: number;
  repeatCustomerPercentage: number;
  crossBranchCustomersCount: number;
  crossBranchPercentage: number;
  branchBookingVolume: { branchId: string; branchName: string; count: number; revenue: number }[];
  stylistBookingCounts: { stylistId: string; stylistName: string; branchName: string; count: number; repeatRate: number }[];
  serviceBookingCounts: { serviceId: string; serviceName: string; category: string; count: number; repeatCount: number }[];
}

export type CustomerTab = 'HOME' | 'APPOINTMENTS' | 'HISTORY' | 'PROFILE';
export type AdminTab = 'Dashboard' | 'Branches' | 'Stylists' | 'Services' | 'Customers' | 'Appointments' | 'Analytics' | 'Profile';
