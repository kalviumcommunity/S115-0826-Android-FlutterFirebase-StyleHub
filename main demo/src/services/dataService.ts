import { 
  Branch, 
  Stylist, 
  SalonService, 
  Appointment, 
  UserProfile, 
  NetworkAnalytics, 
  CustomerNetworkInsight,
  AppointmentStatus 
} from '../types';
import { 
  INITIAL_BRANCHES, 
  INITIAL_SERVICES, 
  INITIAL_STYLISTS, 
  INITIAL_APPOINTMENTS, 
  DEMO_USERS 
} from '../data/seedData';
import { db } from '../firebase/config';
import { doc, setDoc, updateDoc } from 'firebase/firestore';

// Storage keys
const STORAGE_KEYS = {
  BRANCHES: 'stylehub_branches_v1',
  SERVICES: 'stylehub_services_v1',
  STYLISTS: 'stylehub_stylists_v1',
  APPOINTMENTS: 'stylehub_appointments_v1',
  USERS: 'stylehub_users_v1',
  CURRENT_USER: 'stylehub_current_user_v1',
};

// Event listener subscribers for real-time reactivity
type Listener<T> = (data: T) => void;
const appointmentListeners: Set<Listener<Appointment[]>> = new Set();
const branchListeners: Set<Listener<Branch[]>> = new Set();
const stylistListeners: Set<Listener<Stylist[]>> = new Set();
const serviceListeners: Set<Listener<SalonService[]>> = new Set();

// Helper to notify listeners
function notifyAppointments(data: Appointment[]) {
  appointmentListeners.forEach(l => l(data));
}
function notifyBranches(data: Branch[]) {
  branchListeners.forEach(l => l(data));
}
function notifyStylists(data: Stylist[]) {
  stylistListeners.forEach(l => l(data));
}
function notifyServices(data: SalonService[]) {
  serviceListeners.forEach(l => l(data));
}

// DataService: Implements Provider -> Repository -> Service pattern
class DataService {
  private branches: Branch[] = [];
  private services: SalonService[] = [];
  private stylists: Stylist[] = [];
  private appointments: Appointment[] = [];
  private users: Record<string, UserProfile> = {};

  constructor() {
    this.init();
  }

  private init() {
    try {
      const storedBranches = localStorage.getItem(STORAGE_KEYS.BRANCHES);
      this.branches = storedBranches ? JSON.parse(storedBranches) : [...INITIAL_BRANCHES];

      const storedServices = localStorage.getItem(STORAGE_KEYS.SERVICES);
      this.services = storedServices ? JSON.parse(storedServices) : [...INITIAL_SERVICES];

      const storedStylists = localStorage.getItem(STORAGE_KEYS.STYLISTS);
      this.stylists = storedStylists ? JSON.parse(storedStylists) : [...INITIAL_STYLISTS];

      const storedAppointments = localStorage.getItem(STORAGE_KEYS.APPOINTMENTS);
      this.appointments = storedAppointments ? JSON.parse(storedAppointments) : [...INITIAL_APPOINTMENTS];

      const storedUsers = localStorage.getItem(STORAGE_KEYS.USERS);
      this.users = storedUsers ? JSON.parse(storedUsers) : { ...DEMO_USERS };

      // Save initial cache if first run
      if (!storedBranches) this.persist(STORAGE_KEYS.BRANCHES, this.branches);
      if (!storedServices) this.persist(STORAGE_KEYS.SERVICES, this.services);
      if (!storedStylists) this.persist(STORAGE_KEYS.STYLISTS, this.stylists);
      if (!storedAppointments) this.persist(STORAGE_KEYS.APPOINTMENTS, this.appointments);
      if (!storedUsers) this.persist(STORAGE_KEYS.USERS, this.users);
    } catch {
      this.branches = [...INITIAL_BRANCHES];
      this.services = [...INITIAL_SERVICES];
      this.stylists = [...INITIAL_STYLISTS];
      this.appointments = [...INITIAL_APPOINTMENTS];
      this.users = { ...DEMO_USERS };
    }
  }

  private persist(key: string, data: unknown) {
    try {
      localStorage.setItem(key, JSON.stringify(data));
    } catch (e) {
      console.warn('Storage persistence failed:', e);
    }
  }

  // Real-time subscribers (mirroring Firestore onSnapshot)
  subscribeAppointments(callback: Listener<Appointment[]>): () => void {
    appointmentListeners.add(callback);
    callback([...this.appointments]);
    return () => appointmentListeners.delete(callback);
  }

  subscribeBranches(callback: Listener<Branch[]>): () => void {
    branchListeners.add(callback);
    callback([...this.branches]);
    return () => branchListeners.delete(callback);
  }

  subscribeStylists(callback: Listener<Stylist[]>): () => void {
    stylistListeners.add(callback);
    callback([...this.stylists]);
    return () => stylistListeners.delete(callback);
  }

  subscribeServices(callback: Listener<SalonService[]>): () => void {
    serviceListeners.add(callback);
    callback([...this.services]);
    return () => serviceListeners.delete(callback);
  }

  // BRANCH OPERATIONS
  getBranches(): Branch[] {
    return [...this.branches];
  }

  getBranchById(branchId: string): Branch | undefined {
    return this.branches.find(b => b.branchId === branchId);
  }

  saveBranch(branch: Branch): Branch {
    const idx = this.branches.findIndex(b => b.branchId === branch.branchId);
    if (idx >= 0) {
      this.branches[idx] = branch;
    } else {
      this.branches.push(branch);
    }
    this.persist(STORAGE_KEYS.BRANCHES, this.branches);
    notifyBranches(this.branches);
    return branch;
  }

  toggleBranchStatus(branchId: string): Branch | undefined {
    const branch = this.branches.find(b => b.branchId === branchId);
    if (branch) {
      branch.active = !branch.active;
      this.persist(STORAGE_KEYS.BRANCHES, this.branches);
      notifyBranches(this.branches);
    }
    return branch;
  }

  deleteBranch(branchId: string): boolean {
    const before = this.branches.length;
    this.branches = this.branches.filter(b => b.branchId !== branchId);
    if (this.branches.length !== before) {
      this.persist(STORAGE_KEYS.BRANCHES, this.branches);
      notifyBranches(this.branches);
      return true;
    }
    return false;
  }

  // STYLIST OPERATIONS
  getStylists(): Stylist[] {
    return [...this.stylists];
  }

  getStylistsByBranch(branchId: string): Stylist[] {
    return this.stylists.filter(s => s.branchId === branchId && s.active);
  }

  getStylistById(stylistId: string): Stylist | undefined {
    return this.stylists.find(s => s.stylistId === stylistId);
  }

  saveStylist(stylist: Stylist): Stylist {
    const idx = this.stylists.findIndex(s => s.stylistId === stylist.stylistId);
    const branch = this.getBranchById(stylist.branchId);
    if (branch) {
      stylist.branchName = branch.name;
    }
    if (idx >= 0) {
      this.stylists[idx] = stylist;
    } else {
      this.stylists.push(stylist);
    }
    this.persist(STORAGE_KEYS.STYLISTS, this.stylists);
    notifyStylists(this.stylists);
    return stylist;
  }

  toggleStylistStatus(stylistId: string): Stylist | undefined {
    const stylist = this.stylists.find(s => s.stylistId === stylistId);
    if (stylist) {
      stylist.active = !stylist.active;
      this.persist(STORAGE_KEYS.STYLISTS, this.stylists);
      notifyStylists(this.stylists);
    }
    return stylist;
  }

  deleteStylist(stylistId: string): boolean {
    const before = this.stylists.length;
    this.stylists = this.stylists.filter(s => s.stylistId !== stylistId);
    if (this.stylists.length !== before) {
      this.persist(STORAGE_KEYS.STYLISTS, this.stylists);
      notifyStylists(this.stylists);
      return true;
    }
    return false;
  }

  // SERVICE OPERATIONS
  getServices(): SalonService[] {
    return [...this.services];
  }

  getServiceById(serviceId: string): SalonService | undefined {
    return this.services.find(s => s.serviceId === serviceId);
  }

  saveService(service: SalonService): SalonService {
    const idx = this.services.findIndex(s => s.serviceId === service.serviceId);
    if (idx >= 0) {
      this.services[idx] = service;
    } else {
      this.services.push(service);
    }
    this.persist(STORAGE_KEYS.SERVICES, this.services);
    notifyServices(this.services);
    return service;
  }

  toggleServiceStatus(serviceId: string): SalonService | undefined {
    const service = this.services.find(s => s.serviceId === serviceId);
    if (service) {
      service.active = !service.active;
      this.persist(STORAGE_KEYS.SERVICES, this.services);
      notifyServices(this.services);
    }
    return service;
  }

  deleteService(serviceId: string): boolean {
    const before = this.services.length;
    this.services = this.services.filter(s => s.serviceId !== serviceId);
    if (this.services.length !== before) {
      this.persist(STORAGE_KEYS.SERVICES, this.services);
      notifyServices(this.services);
      return true;
    }
    return false;
  }

  // APPOINTMENT OPERATIONS (Centralized Global Customer ID Core)
  getAppointments(): Appointment[] {
    return [...this.appointments];
  }

  getCustomerAppointments(customerId: string): Appointment[] {
    return this.appointments
      .filter(a => a.customerId === customerId)
      .sort((a, b) => new Date(b.appointmentDate).getTime() - new Date(a.appointmentDate).getTime());
  }

  getBranchAppointments(branchId: string): Appointment[] {
    return this.appointments
      .filter(a => a.branchId === branchId)
      .sort((a, b) => new Date(b.appointmentDate).getTime() - new Date(a.appointmentDate).getTime());
  }

  getStylistAppointments(stylistId: string): Appointment[] {
    return this.appointments
      .filter(a => a.stylistId === stylistId)
      .sort((a, b) => new Date(b.appointmentDate).getTime() - new Date(a.appointmentDate).getTime());
  }

  // Prevent double bookings
  isSlotAvailable(stylistId: string, appointmentDate: string, startTime: string, excludeAppointmentId?: string): boolean {
    return !this.appointments.some(a => 
      a.stylistId === stylistId &&
      a.appointmentDate === appointmentDate &&
      a.startTime === startTime &&
      a.status !== 'Cancelled' &&
      a.appointmentId !== excludeAppointmentId
    );
  }

  createAppointment(payload: {
    customerId: string;
    customerName: string;
    customerPhone: string;
    customerEmail: string;
    branchId: string;
    stylistId: string;
    serviceId: string;
    appointmentDate: string;
    startTime: string;
    notes?: string;
  }): Appointment {
    // Validate slot availability
    if (!this.isSlotAvailable(payload.stylistId, payload.appointmentDate, payload.startTime)) {
      throw new Error(`The selected slot ${payload.startTime} with this stylist is already booked. Please choose another time.`);
    }

    const branch = this.getBranchById(payload.branchId);
    const stylist = this.getStylistById(payload.stylistId);
    const service = this.getServiceById(payload.serviceId);

    if (!branch) throw new Error('Invalid salon branch selected.');
    if (!stylist) throw new Error('Invalid stylist selected.');
    if (!service) throw new Error('Invalid service selected.');

    // Calculate approx end time based on service duration
    const endTime = this.calculateEndTime(payload.startTime, service.duration);

    const newAppointment: Appointment = {
      appointmentId: `apt_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
      customerId: payload.customerId,
      customerName: payload.customerName,
      customerPhone: payload.customerPhone,
      customerEmail: payload.customerEmail,
      branchId: branch.branchId,
      branchName: branch.name,
      stylistId: stylist.stylistId,
      stylistName: stylist.name,
      serviceId: service.serviceId,
      serviceName: service.name,
      servicePrice: service.price,
      appointmentDate: payload.appointmentDate,
      startTime: payload.startTime,
      endTime,
      status: 'Confirmed',
      notes: payload.notes || '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    this.appointments.unshift(newAppointment);
    this.persist(STORAGE_KEYS.APPOINTMENTS, this.appointments);
    notifyAppointments(this.appointments);

    // Asynchronous Cloud Firestore background synchronization
    try {
      setDoc(doc(db, 'appointments', newAppointment.appointmentId), newAppointment).catch(err => {
        console.info('Firestore offline/background sync notice:', err?.message || err);
      });
    } catch (e) {
      console.info('Firestore sync dispatch:', e);
    }

    return newAppointment;
  }

  updateAppointmentStatus(appointmentId: string, status: AppointmentStatus, notes?: string): Appointment {
    const apt = this.appointments.find(a => a.appointmentId === appointmentId);
    if (!apt) throw new Error('Appointment not found.');

    apt.status = status;
    apt.updatedAt = new Date().toISOString();
    if (notes !== undefined) apt.notes = notes;

    this.persist(STORAGE_KEYS.APPOINTMENTS, this.appointments);
    notifyAppointments(this.appointments);

    // Asynchronous Cloud Firestore update
    try {
      updateDoc(doc(db, 'appointments', appointmentId), {
        status,
        updatedAt: apt.updatedAt,
        ...(notes !== undefined ? { notes } : {})
      }).catch(err => {
        console.info('Firestore update notice:', err?.message || err);
      });
    } catch (e) {
      console.info('Firestore update dispatch:', e);
    }

    return apt;
  }

  cancelAppointment(appointmentId: string, reason?: string): Appointment {
    return this.updateAppointmentStatus(
      appointmentId, 
      'Cancelled', 
      reason ? `Cancelled: ${reason}` : 'Cancelled by customer'
    );
  }

  // Cross-branch customer recognition:
  // Given a customer global UID, retrieve their complete journey across all branches
  getCustomerNetworkProfile(customerId: string): CustomerNetworkInsight | null {
    const customerBookings = this.appointments.filter(a => a.customerId === customerId);
    if (customerBookings.length === 0) return null;

    const branchesSet = new Set<string>();
    const stylistsSet = new Set<string>();
    const servicesCount: Record<string, number> = {};
    let totalSpent = 0;
    let completedCount = 0;

    customerBookings.forEach(b => {
      branchesSet.add(b.branchName);
      stylistsSet.add(b.stylistName);
      servicesCount[b.serviceName] = (servicesCount[b.serviceName] || 0) + 1;
      if (b.status !== 'Cancelled') {
        totalSpent += b.servicePrice;
      }
      if (b.status === 'Completed') {
        completedCount++;
      }
    });

    // Find favorite service
    let favoriteService = '';
    let maxSrvCount = 0;
    Object.entries(servicesCount).forEach(([srv, count]) => {
      if (count > maxSrvCount) {
        maxSrvCount = count;
        favoriteService = srv;
      }
    });

    const first = customerBookings[customerBookings.length - 1];
    const latest = customerBookings[0];

    return {
      customerId,
      customerName: latest.customerName,
      customerEmail: latest.customerEmail,
      customerPhone: latest.customerPhone,
      totalBookings: customerBookings.length,
      completedBookings: completedCount,
      branchesVisited: Array.from(branchesSet),
      stylistsUsed: Array.from(stylistsSet),
      favoriteService: favoriteService || 'Signature Haircut',
      isRepeatCustomer: customerBookings.length >= 2,
      isCrossBranchCustomer: branchesSet.size >= 2,
      firstVisitDate: first.appointmentDate,
      lastVisitDate: latest.appointmentDate,
      totalSpent,
    };
  }

  // Real-time network analytics calculation from true appointment records
  getNetworkAnalytics(): NetworkAnalytics {
    const totalCustomersMap = new Map<string, { bookings: number; branches: Set<string>; spent: number }>();
    const branchVolume: Record<string, { name: string; count: number; revenue: number }> = {};
    const stylistVolume: Record<string, { name: string; branchName: string; count: number; customers: Set<string> }> = {};
    const serviceVolume: Record<string, { name: string; category: string; count: number; customers: Set<string> }> = {};

    let completedBookings = 0;
    let cancelledBookings = 0;

    // Initialize branches in volume map
    this.branches.forEach(b => {
      branchVolume[b.branchId] = { name: b.name, count: 0, revenue: 0 };
    });

    // Initialize stylists in volume map
    this.stylists.forEach(s => {
      stylistVolume[s.stylistId] = { 
        name: s.name, 
        branchName: s.branchName || 'StyleHub', 
        count: 0, 
        customers: new Set() 
      };
    });

    // Process all bookings
    this.appointments.forEach(apt => {
      if (apt.status === 'Completed') completedBookings++;
      if (apt.status === 'Cancelled') cancelledBookings++;

      // Customer metrics
      if (!totalCustomersMap.has(apt.customerId)) {
        totalCustomersMap.set(apt.customerId, { bookings: 0, branches: new Set(), spent: 0 });
      }
      const c = totalCustomersMap.get(apt.customerId)!;
      c.bookings++;
      c.branches.add(apt.branchId);
      if (apt.status !== 'Cancelled') c.spent += apt.servicePrice;

      // Branch metrics
      if (!branchVolume[apt.branchId]) {
        branchVolume[apt.branchId] = { name: apt.branchName, count: 0, revenue: 0 };
      }
      branchVolume[apt.branchId].count++;
      if (apt.status !== 'Cancelled') {
        branchVolume[apt.branchId].revenue += apt.servicePrice;
      }

      // Stylist metrics
      if (!stylistVolume[apt.stylistId]) {
        stylistVolume[apt.stylistId] = { 
          name: apt.stylistName, 
          branchName: apt.branchName, 
          count: 0, 
          customers: new Set() 
        };
      }
      stylistVolume[apt.stylistId].count++;
      stylistVolume[apt.stylistId].customers.add(apt.customerId);

      // Service metrics
      if (!serviceVolume[apt.serviceId]) {
        const srv = this.getServiceById(apt.serviceId);
        serviceVolume[apt.serviceId] = {
          name: apt.serviceName,
          category: srv?.category || 'General',
          count: 0,
          customers: new Set()
        };
      }
      serviceVolume[apt.serviceId].count++;
      serviceVolume[apt.serviceId].customers.add(apt.customerId);
    });

    // Calculate customer counts
    const totalCustomers = totalCustomersMap.size;
    let repeatCustomersCount = 0;
    let crossBranchCustomersCount = 0;

    totalCustomersMap.forEach(c => {
      if (c.bookings >= 2) repeatCustomersCount++;
      if (c.branches.size >= 2) crossBranchCustomersCount++;
    });

    const repeatCustomerPercentage = totalCustomers > 0 
      ? Math.round((repeatCustomersCount / totalCustomers) * 100) 
      : 0;

    const crossBranchPercentage = totalCustomers > 0 
      ? Math.round((crossBranchCustomersCount / totalCustomers) * 100) 
      : 0;

    return {
      totalCustomers,
      totalBranches: this.branches.filter(b => b.active).length,
      totalStylists: this.stylists.filter(s => s.active).length,
      totalServices: this.services.filter(s => s.active).length,
      totalBookings: this.appointments.length,
      completedBookings,
      cancelledBookings,
      repeatCustomersCount,
      repeatCustomerPercentage,
      crossBranchCustomersCount,
      crossBranchPercentage,
      branchBookingVolume: Object.entries(branchVolume).map(([branchId, v]) => ({
        branchId,
        branchName: v.name,
        count: v.count,
        revenue: v.revenue
      })).sort((a, b) => b.count - a.count),
      stylistBookingCounts: Object.entries(stylistVolume).map(([stylistId, v]) => ({
        stylistId,
        stylistName: v.name,
        branchName: v.branchName,
        count: v.count,
        repeatRate: v.count > 0 ? Math.round(((v.count - v.customers.size) / v.count) * 100) : 0
      })).sort((a, b) => b.count - a.count),
      serviceBookingCounts: Object.entries(serviceVolume).map(([serviceId, v]) => ({
        serviceId,
        serviceName: v.name,
        category: v.category,
        count: v.count,
        repeatCount: Math.max(0, v.count - v.customers.size)
      })).sort((a, b) => b.count - a.count),
    };
  }

  // Reset to default seed data (useful for QA verification)
  resetToDemoData() {
    this.branches = [...INITIAL_BRANCHES];
    this.services = [...INITIAL_SERVICES];
    this.stylists = [...INITIAL_STYLISTS];
    this.appointments = [...INITIAL_APPOINTMENTS];
    this.users = { ...DEMO_USERS };

    this.persist(STORAGE_KEYS.BRANCHES, this.branches);
    this.persist(STORAGE_KEYS.SERVICES, this.services);
    this.persist(STORAGE_KEYS.STYLISTS, this.stylists);
    this.persist(STORAGE_KEYS.APPOINTMENTS, this.appointments);
    this.persist(STORAGE_KEYS.USERS, this.users);

    notifyBranches(this.branches);
    notifyServices(this.services);
    notifyStylists(this.stylists);
    notifyAppointments(this.appointments);
  }

  private calculateEndTime(startStr: string, durationMinutes: number): string {
    try {
      const match = startStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
      if (!match) return startStr;
      let hours = parseInt(match[1], 10);
      const minutes = parseInt(match[2], 10);
      const ampm = match[3].toUpperCase();

      if (ampm === 'PM' && hours < 12) hours += 12;
      if (ampm === 'AM' && hours === 12) hours = 0;

      const totalMinutes = hours * 60 + minutes + durationMinutes;
      const endHours24 = Math.floor(totalMinutes / 60) % 24;
      const endMinutes = totalMinutes % 60;

      const endAmpm = endHours24 >= 12 ? 'PM' : 'AM';
      let endHours12 = endHours24 % 12;
      if (endHours12 === 0) endHours12 = 12;

      return `${endHours12.toString().padStart(2, '0')}:${endMinutes.toString().padStart(2, '0')} ${endAmpm}`;
    } catch {
      return startStr;
    }
  }
}

export const dataService = new DataService();
