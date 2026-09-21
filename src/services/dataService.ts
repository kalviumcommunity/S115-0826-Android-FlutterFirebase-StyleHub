import { useState, useEffect } from 'react';
import { 
  Branch, 
  Stylist, 
  SalonService, 
  Appointment, 
  UserProfile, 
  NetworkAnalytics, 
  CustomerNetworkInsight,
  AppointmentStatus,
  AppointmentSlot
} from '../types';
import { db } from '../firebase/config';
import { 
  collection, 
  doc, 
  getDoc,
  getDocs,
  setDoc, 
  updateDoc, 
  deleteDoc,
  onSnapshot,
  query,
  where,
  runTransaction,
  orderBy
} from 'firebase/firestore';
import { useAuth } from '../context/AuthContext';

// ---------------------------------------------------------
// React Hooks for Real-Time Data
// ---------------------------------------------------------

export function useBranches() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'branches'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map(d => d.data() as Branch);
      setBranches(data);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching branches:", error);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return { branches, loading };
}

export function useServices() {
  const [services, setServices] = useState<SalonService[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'services'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map(d => d.data() as SalonService);
      setServices(data);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return { services, loading };
}

export function useStylists() {
  const [stylists, setStylists] = useState<Stylist[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'stylists'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map(d => d.data() as Stylist);
      setStylists(data);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return { stylists, loading };
}

export function useAppointments(userId: string | undefined, role: string | undefined, branchId?: string) {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!userId || !role) {
      setAppointments([]);
      setLoading(false);
      return;
    }

    let q;
    if (role === 'customer') {
      q = query(collection(db, 'appointments'), where('customerId', '==', userId));
    } else if (role === 'staff' && branchId) {
      q = query(collection(db, 'appointments'), where('branchId', '==', branchId));
    } else if (role === 'admin') {
      q = query(collection(db, 'appointments'));
    } else {
      setAppointments([]);
      setLoading(false);
      return;
    }

    const unsubscribe = onSnapshot(q, (snapshot) => {
      let data = snapshot.docs.map(d => d.data() as Appointment);
      // Sort by date/time descending locally since we didn't add composite indexes yet
      data.sort((a, b) => {
        const timeA = new Date(`${a.appointmentDate} ${a.startTime}`).getTime();
        const timeB = new Date(`${b.appointmentDate} ${b.startTime}`).getTime();
        return timeB - timeA;
      });
      setAppointments(data);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching appointments:", error);
      setLoading(false);
    });
    return unsubscribe;
  }, [userId, role, branchId]);

  return { appointments, loading };
}

export function useCustomerAppointments(customerId: string | null) {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!customerId) {
      setAppointments([]);
      return;
    }
    setLoading(true);
    const q = query(collection(db, 'appointments'), where('customerId', '==', customerId));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      let data = snapshot.docs.map(d => d.data() as Appointment);
      data.sort((a, b) => {
        const timeA = new Date(`${a.appointmentDate} ${a.startTime}`).getTime();
        const timeB = new Date(`${b.appointmentDate} ${b.startTime}`).getTime();
        return timeB - timeA;
      });
      setAppointments(data);
      setLoading(false);
    });
    return unsubscribe;
  }, [customerId]);

  return { customerAppointments: appointments, loadingCustomerApts: loading };
}

export function useStylistSlots(stylistId: string | undefined, date: string) {
  const [bookedSlots, setBookedSlots] = useState<string[]>([]);

  useEffect(() => {
    if (!stylistId || !date) {
      setBookedSlots([]);
      return;
    }
    const q = query(
      collection(db, 'appointmentSlots'), 
      where('stylistId', '==', stylistId),
      where('appointmentDate', '==', date)
    );
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const slots = snapshot.docs.map(d => d.data().startTime as string);
      setBookedSlots(slots);
    });
    return unsubscribe;
  }, [stylistId, date]);

  return bookedSlots;
}

// ---------------------------------------------------------
// Transactional Booking Operations
// ---------------------------------------------------------

export const bookingService = {
  
  async createAppointment(payload: {
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
    serviceDuration: number;
    appointmentDate: string;
    startTime: string;
    notes?: string;
  }): Promise<Appointment> {
    
    // Create deterministic slot ID to prevent double booking
    const slotId = `slot_${payload.branchId}_${payload.stylistId}_${payload.appointmentDate}_${payload.startTime.replace(/\s+/g, '')}`;
    const appointmentId = `apt_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    
    const endTime = calculateEndTime(payload.startTime, payload.serviceDuration);

    const appointment: Appointment = {
      appointmentId,
      customerId: payload.customerId,
      customerName: payload.customerName,
      customerPhone: payload.customerPhone,
      customerEmail: payload.customerEmail,
      branchId: payload.branchId,
      branchName: payload.branchName,
      stylistId: payload.stylistId,
      stylistName: payload.stylistName,
      serviceId: payload.serviceId,
      serviceName: payload.serviceName,
      servicePrice: payload.servicePrice,
      appointmentDate: payload.appointmentDate,
      startTime: payload.startTime,
      endTime,
      status: 'Confirmed',
      notes: payload.notes || '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const slot: AppointmentSlot = {
      slotId,
      branchId: payload.branchId,
      stylistId: payload.stylistId,
      appointmentDate: payload.appointmentDate,
      startTime: payload.startTime,
      appointmentId: appointment.appointmentId,
      customerId: payload.customerId,
      createdAt: new Date().toISOString()
    };

    await runTransaction(db, async (transaction) => {
      const slotRef = doc(db, 'appointmentSlots', slotId);
      const slotDoc = await transaction.get(slotRef);

      if (slotDoc.exists()) {
        throw new Error(`The selected slot ${payload.startTime} is already booked. Please choose another time.`);
      }

      const aptRef = doc(db, 'appointments', appointment.appointmentId);
      transaction.set(slotRef, slot);
      transaction.set(aptRef, appointment);
    });

    return appointment;
  },

  async cancelAppointment(appointment: Appointment, reason?: string): Promise<void> {
    const slotId = `slot_${appointment.branchId}_${appointment.stylistId}_${appointment.appointmentDate}_${appointment.startTime.replace(/\s+/g, '')}`;
    
    await runTransaction(db, async (transaction) => {
      const aptRef = doc(db, 'appointments', appointment.appointmentId);
      const slotRef = doc(db, 'appointmentSlots', slotId);
      
      const aptDoc = await transaction.get(aptRef);
      if (!aptDoc.exists()) throw new Error('Appointment not found.');

      transaction.update(aptRef, {
        status: 'Cancelled',
        notes: reason ? `Cancelled: ${reason}` : 'Cancelled by customer',
        updatedAt: new Date().toISOString()
      });

      // Free up the slot
      transaction.delete(slotRef);
    });
  },

  async rescheduleAppointment(
    appointment: Appointment, 
    newDate: string, 
    newStartTime: string,
    serviceDuration: number
  ): Promise<void> {
    
    const oldSlotId = `slot_${appointment.branchId}_${appointment.stylistId}_${appointment.appointmentDate}_${appointment.startTime.replace(/\s+/g, '')}`;
    const newSlotId = `slot_${appointment.branchId}_${appointment.stylistId}_${newDate}_${newStartTime.replace(/\s+/g, '')}`;
    const newEndTime = calculateEndTime(newStartTime, serviceDuration);

    await runTransaction(db, async (transaction) => {
      const aptRef = doc(db, 'appointments', appointment.appointmentId);
      const oldSlotRef = doc(db, 'appointmentSlots', oldSlotId);
      const newSlotRef = doc(db, 'appointmentSlots', newSlotId);

      // Verify the new slot is available
      const newSlotDoc = await transaction.get(newSlotRef);
      if (newSlotDoc.exists()) {
        throw new Error(`The selected slot ${newStartTime} is already booked. Please choose another time.`);
      }

      // Reserve the new slot
      transaction.set(newSlotRef, {
        slotId: newSlotId,
        branchId: appointment.branchId,
        stylistId: appointment.stylistId,
        appointmentDate: newDate,
        startTime: newStartTime,
        appointmentId: appointment.appointmentId,
        customerId: appointment.customerId,
        createdAt: new Date().toISOString()
      });

      // Release the old slot
      transaction.delete(oldSlotRef);

      // Update the appointment
      transaction.update(aptRef, {
        appointmentDate: newDate,
        startTime: newStartTime,
        endTime: newEndTime,
        updatedAt: new Date().toISOString()
      });
    });
  },
  
  async updateAppointmentStatus(appointmentId: string, status: AppointmentStatus, notes?: string): Promise<void> {
     const aptRef = doc(db, 'appointments', appointmentId);
     const updateData: any = { status, updatedAt: new Date().toISOString() };
     if (notes !== undefined) updateData.notes = notes;
     await updateDoc(aptRef, updateData);
  }
};

// ---------------------------------------------------------
// Admin/Management Operations
// ---------------------------------------------------------

export const adminService = {
  async saveBranch(branch: Branch) {
    const ref = doc(db, 'branches', branch.branchId);
    await setDoc(ref, branch);
  },
  async toggleBranchStatus(branchId: string, currentStatus: boolean) {
    const ref = doc(db, 'branches', branchId);
    await updateDoc(ref, { active: !currentStatus });
  },
  async saveStylist(stylist: Stylist) {
    const ref = doc(db, 'stylists', stylist.stylistId);
    await setDoc(ref, stylist);
  },
  async toggleStylistStatus(stylistId: string, currentStatus: boolean) {
    const ref = doc(db, 'stylists', stylistId);
    await updateDoc(ref, { active: !currentStatus });
  },
  async saveService(service: SalonService) {
    const ref = doc(db, 'services', service.serviceId);
    await setDoc(ref, service);
  },
  async toggleServiceStatus(serviceId: string, currentStatus: boolean) {
    await updateDoc(doc(db, 'services', serviceId), { active: !currentStatus });
  }
};

// ---------------------------------------------------------
// Helper & Analytics Methods
// ---------------------------------------------------------

export function getCustomerNetworkProfile(appointments: Appointment[], customerId: string): CustomerNetworkInsight | null {
  const customerBookings = appointments.filter(a => a.customerId === customerId);
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

export function getNetworkAnalytics(
  appointments: Appointment[],
  branches: Branch[],
  stylists: Stylist[],
  services: SalonService[]
): NetworkAnalytics {
  const totalCustomersMap = new Map<string, { bookings: number; branches: Set<string>; spent: number }>();
  const branchVolume: Record<string, { name: string; count: number; revenue: number }> = {};
  const stylistVolume: Record<string, { name: string; branchName: string; count: number; customers: Set<string> }> = {};
  const serviceVolume: Record<string, { name: string; category: string; count: number; customers: Set<string> }> = {};

  let completedBookings = 0;
  let cancelledBookings = 0;

  branches.forEach(b => {
    branchVolume[b.branchId] = { name: b.name, count: 0, revenue: 0 };
  });

  stylists.forEach(s => {
    stylistVolume[s.stylistId] = { 
      name: s.name, 
      branchName: s.branchName || 'StyleHub', 
      count: 0, 
      customers: new Set() 
    };
  });

  appointments.forEach(apt => {
    if (apt.status === 'Completed') completedBookings++;
    if (apt.status === 'Cancelled') cancelledBookings++;

    if (!totalCustomersMap.has(apt.customerId)) {
      totalCustomersMap.set(apt.customerId, { bookings: 0, branches: new Set(), spent: 0 });
    }
    const c = totalCustomersMap.get(apt.customerId)!;
    c.bookings++;
    c.branches.add(apt.branchId);
    if (apt.status !== 'Cancelled') c.spent += apt.servicePrice;

    if (!branchVolume[apt.branchId]) {
      branchVolume[apt.branchId] = { name: apt.branchName, count: 0, revenue: 0 };
    }
    branchVolume[apt.branchId].count++;
    if (apt.status !== 'Cancelled') {
      branchVolume[apt.branchId].revenue += apt.servicePrice;
    }

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

    if (!serviceVolume[apt.serviceId]) {
      const srv = services.find(s => s.serviceId === apt.serviceId);
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

  const totalCustomers = totalCustomersMap.size;
  let repeatCustomersCount = 0;
  let crossBranchCustomersCount = 0;

  totalCustomersMap.forEach(c => {
    if (c.bookings >= 2) repeatCustomersCount++;
    if (c.branches.size >= 2) crossBranchCustomersCount++;
  });

  return {
    totalCustomers,
    totalBranches: branches.filter(b => b.active).length,
    totalStylists: stylists.filter(s => s.active).length,
    totalServices: services.filter(s => s.active).length,
    totalBookings: appointments.length,
    completedBookings,
    cancelledBookings,
    repeatCustomersCount,
    repeatCustomerPercentage: totalCustomers > 0 ? Math.round((repeatCustomersCount / totalCustomers) * 100) : 0,
    crossBranchCustomersCount,
    crossBranchPercentage: totalCustomers > 0 ? Math.round((crossBranchCustomersCount / totalCustomers) * 100) : 0,
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

function calculateEndTime(startStr: string, durationMinutes: number): string {
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
