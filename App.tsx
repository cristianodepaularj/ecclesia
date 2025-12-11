import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Login } from './pages/Login';
import { AdminDashboard } from './pages/admin/AdminDashboard';
import { AdminMembers } from './pages/admin/AdminMembers';
import { AdminFinance } from './pages/admin/AdminFinance';
import { AdminEvents } from './pages/admin/AdminEvents';
import { AdminNews } from './pages/admin/AdminNews';
import { MemberHome } from './pages/member/MemberHome';
import { MemberBible } from './pages/member/MemberBible';
import { MemberDonation } from './pages/member/MemberDonation';
import { MemberSchedule } from './pages/member/MemberSchedule';

const AppRoutes: React.FC = () => {
  const { session, role } = useAuth();

  return (
    <Routes>
      <Route
        path="/login"
        element={!session ? <Login /> : <Navigate to={role === 'admin' ? '/admin' : '/member'} replace />}
      />

      {/* Admin Routes */}
      <Route element={<ProtectedRoute allowedRole="admin" />}>
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/admin/members" element={<AdminMembers />} />
        <Route path="/admin/finance" element={<AdminFinance />} />
        <Route path="/admin/events" element={<AdminEvents />} />
        <Route path="/admin/news" element={<AdminNews />} />
      </Route>

      {/* Member Routes */}
      <Route element={<ProtectedRoute />}>
        <Route path="/member" element={<MemberHome />} />
        <Route path="/member/bible" element={<MemberBible />} />
        <Route path="/member/schedule" element={<MemberSchedule />} />
        <Route path="/member/donate" element={<MemberDonation />} />
      </Route>

      {/* Default Redirect */}
      <Route path="*" element={<Navigate to={session ? (role === 'admin' ? '/admin' : '/member') : '/login'} replace />} />
    </Routes>
  );
};

const App: React.FC = () => {
  return (
    <HashRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </HashRouter>
  );
};

export default App;