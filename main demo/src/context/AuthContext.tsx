import React, { createContext, useContext, useState, useEffect } from 'react';
import { UserProfile, UserRole } from '../types';
import { DEMO_USERS } from '../data/seedData';

interface AuthContextType {
  currentUser: UserProfile | null;
  role: UserRole;
  isAuthenticated: boolean;
  isLoading: boolean;
  switchRole: (role: UserRole) => void;
  login: (email: string, role?: UserRole) => Promise<boolean>;
  register: (name: string, email: string, phone: string, role?: UserRole) => Promise<boolean>;
  logout: () => void;
  updateProfile: (data: Partial<UserProfile>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const AUTH_STORAGE_KEY = 'stylehub_auth_user_v1';

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      const stored = localStorage.getItem(AUTH_STORAGE_KEY);
      if (stored) {
        setCurrentUser(JSON.parse(stored));
      } else {
        // Default initial session: Customer "Ananya Sharma" with cross-branch history
        const defaultUser = DEMO_USERS.customer;
        setCurrentUser(defaultUser);
        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(defaultUser));
      }
    } catch {
      setCurrentUser(DEMO_USERS.customer);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const switchRole = (newRole: UserRole) => {
    const user = DEMO_USERS[newRole];
    if (user) {
      setCurrentUser(user);
      localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
    }
  };

  const login = async (email: string, targetRole: UserRole = 'customer'): Promise<boolean> => {
    setIsLoading(true);
    // Simulate network authentication roundtrip
    await new Promise(r => setTimeout(r, 400));
    
    // Check demo users first or construct persistent profile
    let matchedUser = Object.values(DEMO_USERS).find(u => u.email.toLowerCase() === email.toLowerCase());
    
    if (!matchedUser) {
      matchedUser = {
        uid: `cust_${Date.now()}`,
        name: email.split('@')[0],
        email,
        phone: '+91 98000 00000',
        role: targetRole,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
    }

    setCurrentUser(matchedUser);
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(matchedUser));
    setIsLoading(false);
    return true;
  };

  const register = async (name: string, email: string, phone: string, targetRole: UserRole = 'customer'): Promise<boolean> => {
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 450));
    
    const newUser: UserProfile = {
      uid: `cust_${Date.now()}`,
      name,
      email,
      phone,
      role: targetRole,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    setCurrentUser(newUser);
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(newUser));
    setIsLoading(false);
    return true;
  };

  const logout = () => {
    localStorage.removeItem(AUTH_STORAGE_KEY);
    // Switch to unauthenticated or prompt login
    setCurrentUser(null);
  };

  const updateProfile = (data: Partial<UserProfile>) => {
    if (!currentUser) return;
    const updated: UserProfile = {
      ...currentUser,
      ...data,
      updatedAt: new Date().toISOString()
    };
    setCurrentUser(updated);
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(updated));
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        role: currentUser?.role || 'customer',
        isAuthenticated: !!currentUser,
        isLoading,
        switchRole,
        login,
        register,
        logout,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
