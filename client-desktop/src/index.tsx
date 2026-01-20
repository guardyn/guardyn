/* @refresh reload */
import { Route, Router } from '@solidjs/router';
import { lazy, Suspense } from 'solid-js';
import { render } from 'solid-js/web';
import App, { AuthProvider, useAuth } from './App';
import { FormLoadingSkeleton, ListLoadingSkeleton, RouteLoadingSkeleton } from './components/shared';
import './styles/index.css';

// =============================================================================
// LAZY-LOADED PAGES (Code Splitting)
// =============================================================================
// Each page is loaded on-demand, reducing initial bundle size.
// Vite will create separate chunks for each lazy import.

// Core pages
const Chat = lazy(() => import('./pages/Chat'));
const Call = lazy(() => import('./pages/Call'));
const CallHistory = lazy(() => import('./pages/CallHistory'));
const Login = lazy(() => import('./pages/Login'));
const Register = lazy(() => import('./pages/Register'));
const Settings = lazy(() => import('./pages/Settings'));

// Group pages
const GroupList = lazy(() => import('./pages/groups/GroupList'));
const GroupCreate = lazy(() => import('./pages/groups/GroupCreate'));
const GroupChat = lazy(() => import('./pages/groups/GroupChat'));
const GroupInfo = lazy(() => import('./pages/groups/GroupInfo'));

// Components (not lazy loaded - small bundle impact)
import IncomingCallDialog from './components/IncomingCall';

// =============================================================================
// AUTH WRAPPER COMPONENTS
// =============================================================================

// Wrapper components that pass auth context to pages
const LoginPage = () => {
  const { setUser } = useAuth();
  return (
    <Suspense fallback={<FormLoadingSkeleton />}>
      <Login onLogin={setUser} />
    </Suspense>
  );
};

const RegisterPage = () => {
  const { setUser } = useAuth();
  return (
    <Suspense fallback={<FormLoadingSkeleton />}>
      <Register onLogin={setUser} />
    </Suspense>
  );
};

// =============================================================================
// RENDER APPLICATION
// =============================================================================

const root = document.getElementById('root');

if (!root) {
  throw new Error('Root element not found');
}

render(
  () => (
    <Router root={(props) => (
      <AuthProvider>
        <App>{props.children}</App>
        <IncomingCallDialog />
      </AuthProvider>
    )}>
      {/* Chat routes */}
      <Route path="/" component={() => (
        <Suspense fallback={<RouteLoadingSkeleton />}>
          <Chat />
        </Suspense>
      )} />
      <Route path="/chat/:conversationId?" component={() => (
        <Suspense fallback={<RouteLoadingSkeleton />}>
          <Chat />
        </Suspense>
      )} />
      
      {/* Call routes */}
      <Route path="/call/:id" component={() => (
        <Suspense fallback={<RouteLoadingSkeleton />}>
          <Call />
        </Suspense>
      )} />
      <Route path="/calls" component={() => (
        <Suspense fallback={<ListLoadingSkeleton />}>
          <CallHistory />
        </Suspense>
      )} />
      
      {/* Group routes */}
      <Route path="/groups" component={() => (
        <Suspense fallback={<ListLoadingSkeleton />}>
          <GroupList />
        </Suspense>
      )} />
      <Route path="/groups/create" component={() => (
        <Suspense fallback={<FormLoadingSkeleton />}>
          <GroupCreate />
        </Suspense>
      )} />
      <Route path="/groups/:id" component={() => (
        <Suspense fallback={<RouteLoadingSkeleton />}>
          <GroupChat />
        </Suspense>
      )} />
      <Route path="/groups/:id/info" component={() => (
        <Suspense fallback={<FormLoadingSkeleton />}>
          <GroupInfo />
        </Suspense>
      )} />
      
      {/* Settings */}
      <Route path="/settings" component={() => (
        <Suspense fallback={<FormLoadingSkeleton />}>
          <Settings />
        </Suspense>
      )} />
      
      {/* Auth routes */}
      <Route path="/login" component={LoginPage} />
      <Route path="/register" component={RegisterPage} />
    </Router>
  ),
  root
);
