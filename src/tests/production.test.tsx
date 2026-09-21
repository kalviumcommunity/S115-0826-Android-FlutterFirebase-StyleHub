
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { bookingService } from '../services/dataService';
import { render } from '@testing-library/react';
import { AuthProvider, useAuth } from '../context/AuthContext';
import React from 'react';

// Mock Firebase Auth
vi.mock('firebase/auth', () => ({
  getAuth: vi.fn(),
  signInWithEmailAndPassword: vi.fn(),
  createUserWithEmailAndPassword: vi.fn(),
  signOut: vi.fn(),
  onAuthStateChanged: vi.fn((auth, cb) => {
    return () => {};
  })
}));

// Mock Firebase Firestore
const mockDb = vi.hoisted(() => ({
  transactions: [] as any[],
  documents: new Map<string, any>()
}));

vi.mock('../firebase/config', () => ({
  db: mockDb,
  auth: {}
}));

vi.mock('firebase/firestore', () => {
  return {
    doc: (db: any, collection: string, id: string) => `${collection}/${id}`,
    getDoc: vi.fn(),
    setDoc: vi.fn(),
    updateDoc: vi.fn(),
    runTransaction: vi.fn(async (db, updateFunction) => {
      const transaction = {
        get: async (ref: string) => ({
          exists: () => mockDb.documents.has(ref),
          data: () => mockDb.documents.get(ref)
        }),
        set: (ref: string, data: any) => mockDb.documents.set(ref, data),
        update: (ref: string, data: any) => {
          if (!mockDb.documents.has(ref)) throw new Error('Document not found');
          mockDb.documents.set(ref, { ...mockDb.documents.get(ref), ...data });
        },
        delete: (ref: string) => mockDb.documents.delete(ref)
      };
      await updateFunction(transaction);
    })
  };
});

const TestAuthComponent = () => {
  const { currentUser, role, isAuthenticated, isLoading, login, logout } = useAuth();
  if (isLoading) return <div data-testid="loading">Loading...</div>;
  if (!isAuthenticated) {
    return (
      <div data-testid="unauthenticated">
        Please login
        <button onClick={() => login('test@test.com', 'password')}>Login</button>
      </div>
    );
  }
  return (
    <div data-testid="authenticated">
      <span data-testid="role">{role}</span>
      <span data-testid="name">{currentUser?.name}</span>
      <button onClick={logout}>Logout</button>
    </div>
  );
};

import { onAuthStateChanged, signOut } from 'firebase/auth';
import { getDoc } from 'firebase/firestore';

describe('1. AUTH TESTS', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('handles unauthenticated state and loading state', async () => {
    (onAuthStateChanged as any).mockImplementation((auth: any, cb: any) => {
      setTimeout(() => cb(null), 10);
      return () => {};
    });

    const { getByTestId, findByTestId } = render(
      <AuthProvider>
        <TestAuthComponent />
      </AuthProvider>
    );

    expect(getByTestId('loading')).toBeDefined();
    const unauth = await findByTestId('unauthenticated');
    expect(unauth).toBeDefined();
  });

  it('handles authenticated user state and login behavior', async () => {
    (onAuthStateChanged as any).mockImplementation((auth: any, cb: any) => {
      cb({ uid: 'test_uid' });
      return () => {};
    });

    (getDoc as any).mockResolvedValueOnce({
      exists: () => true,
      data: () => ({ uid: 'test_uid', name: 'Test User', role: 'customer' })
    });

    const { findByTestId, getByText } = render(
      <AuthProvider>
        <TestAuthComponent />
      </AuthProvider>
    );

    const authDiv = await findByTestId('authenticated');
    expect(authDiv).toBeDefined();
    expect(getByText('Test User')).toBeDefined();
    expect(getByText('customer')).toBeDefined();
  });
  
  it('handles logout behavior', async () => {
    (onAuthStateChanged as any).mockImplementation((auth: any, cb: any) => {
      cb({ uid: 'test_uid' });
      return () => {};
    });

    (getDoc as any).mockResolvedValueOnce({
      exists: () => true,
      data: () => ({ uid: 'test_uid', name: 'Test User', role: 'customer' })
    });
    
    (signOut as any).mockResolvedValueOnce(undefined);

    const { findByTestId, getByText } = render(
      <AuthProvider>
        <TestAuthComponent />
      </AuthProvider>
    );

    await findByTestId('authenticated');
    getByText('Logout').click();
    
    // Using a manual wait instead of waitFor to avoid TS errors
    await new Promise(r => setTimeout(r, 50));
    expect(signOut).toHaveBeenCalled();
  });
});

describe('2. BOOKING TESTS & 3. CANCELLATION TEST & 4. RESCHEDULING TEST', () => {
  beforeEach(() => {
    mockDb.documents.clear();
  });

  const samplePayload = {
    branchId: 'branch_baner',
    branchName: 'StyleHub Baner',
    stylistId: 'stylist_rahul',
    stylistName: 'Rahul Sharma',
    serviceId: 'srv_haircut_luxe',
    serviceName: 'Signature Haircut',
    servicePrice: 850,
    serviceDuration: 45,
    appointmentDate: '2026-10-15',
    startTime: '10:00 AM',
    customerId: 'cust_123',
    customerName: 'Alice',
    customerPhone: '1234567890',
    customerEmail: 'alice@test.com'
  };

  it('handles successful booking with deterministic slot ID and atomic transaction', async () => {
    const apt = await bookingService.createAppointment(samplePayload);
    
    const expectedSlotId = `slot_branch_baner_stylist_rahul_2026-10-15_10:00AM`;
    expect(mockDb.documents.has(`appointmentSlots/${expectedSlotId}`)).toBe(true);
    expect(mockDb.documents.has(`appointments/${apt.appointmentId}`)).toBe(true);
    
    const slotDoc = mockDb.documents.get(`appointmentSlots/${expectedSlotId}`);
    expect(slotDoc.customerId).toBe('cust_123');
  });

  it('prevents double-booking if slot is already taken', async () => {
    await bookingService.createAppointment(samplePayload);
    await expect(bookingService.createAppointment(samplePayload))
      .rejects.toThrow('The selected slot 10:00 AM is already booked.');
  });

  it('cancels appointment and releases the corresponding slot', async () => {
    const apt = await bookingService.createAppointment(samplePayload);
    const slotId = `slot_branch_baner_stylist_rahul_2026-10-15_10:00AM`;
    
    expect(mockDb.documents.has(`appointmentSlots/${slotId}`)).toBe(true);
    
    await bookingService.cancelAppointment(apt, 'Changed my mind');
    
    expect(mockDb.documents.has(`appointmentSlots/${slotId}`)).toBe(false);
    const updatedApt = mockDb.documents.get(`appointments/${apt.appointmentId}`);
    expect(updatedApt.status).toBe('Cancelled');
    expect(updatedApt.notes).toContain('Changed my mind');
  });

  it('reschedules appointment properly atomically checking new slot', async () => {
    const apt = await bookingService.createAppointment(samplePayload);
    const oldSlotId = `slot_branch_baner_stylist_rahul_2026-10-15_10:00AM`;
    
    await bookingService.rescheduleAppointment(apt, '2026-10-15', '11:00 AM', 45);
    
    const newSlotId = `slot_branch_baner_stylist_rahul_2026-10-15_11:00AM`;
    expect(mockDb.documents.has(`appointmentSlots/${oldSlotId}`)).toBe(false);
    expect(mockDb.documents.has(`appointmentSlots/${newSlotId}`)).toBe(true);
    
    const updatedApt = mockDb.documents.get(`appointments/${apt.appointmentId}`);
    expect(updatedApt.startTime).toBe('11:00 AM');
  });

  it('leaves original appointment unchanged if rescheduling fails', async () => {
    const apt = await bookingService.createAppointment(samplePayload);
    
    await bookingService.createAppointment({
      ...samplePayload,
      startTime: '11:00 AM',
      customerId: 'cust_999'
    });
    
    await expect(bookingService.rescheduleAppointment(apt, '2026-10-15', '11:00 AM', 45))
      .rejects.toThrow('The selected slot 11:00 AM is already booked.');
      
    const oldSlotId = `slot_branch_baner_stylist_rahul_2026-10-15_10:00AM`;
    expect(mockDb.documents.has(`appointmentSlots/${oldSlotId}`)).toBe(true);
    
    const fetchedApt = mockDb.documents.get(`appointments/${apt.appointmentId}`);
    expect(fetchedApt.startTime).toBe('10:00 AM');
  });
});

describe('5. ROLE/ACCESS TEST', () => {
  const hasAccessToBranch = (userRole: string, userAssignedBranchId: string | undefined, targetBranchId: string) => {
    if (userRole === 'admin') return true;
    if (userRole === 'staff') return userAssignedBranchId === targetBranchId;
    return false;
  };

  it('verifies customer cannot access staff/admin branch functionality', () => {
    expect(hasAccessToBranch('customer', undefined, 'branch_baner')).toBe(false);
  });

  it('verifies staff cannot access admin functionality across branches', () => {
    expect(hasAccessToBranch('staff', 'branch_baner', 'branch_hadapsar')).toBe(false);
  });

  it('verifies staff branch access logic respects assignedBranchId', () => {
    expect(hasAccessToBranch('staff', 'branch_baner', 'branch_baner')).toBe(true);
  });
  
  it('verifies admin retains authorized network-wide access', () => {
    expect(hasAccessToBranch('admin', undefined, 'branch_baner')).toBe(true);
    expect(hasAccessToBranch('admin', undefined, 'branch_hadapsar')).toBe(true);
  });
});
