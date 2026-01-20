/* @refresh reload */
import { Route, Router } from '@solidjs/router';
import { render } from 'solid-js/web';
import App, { AuthProvider, useAuth } from './App';
import './styles/index.css';

// Pages
import Call from './pages/Call';
import CallHistory from './pages/CallHistory';
import Chat from './pages/Chat';
import Login from './pages/Login';
import Register from './pages/Register';
import Settings from './pages/Settings';
import { GroupChat, GroupCreate, GroupInfo, GroupList } from './pages/groups';

// Components
import IncomingCallDialog from './components/IncomingCall';

// Wrapper components that pass auth context to pages
const LoginPage = () => {
  const { setUser } = useAuth();
  return <Login onLogin={setUser} />;
};

const RegisterPage = () => {
  const { setUser } = useAuth();
  return <Register onLogin={setUser} />;
};

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
      <Route path="/" component={Chat} />
      <Route path="/chat/:conversationId?" component={Chat} />
      <Route path="/call/:id" component={Call} />
      <Route path="/calls" component={CallHistory} />
      <Route path="/groups" component={GroupList} />
      <Route path="/groups/create" component={GroupCreate} />
      <Route path="/groups/:id" component={GroupChat} />
      <Route path="/groups/:id/info" component={GroupInfo} />
      <Route path="/settings" component={Settings} />
      <Route path="/login" component={LoginPage} />
      <Route path="/register" component={RegisterPage} />
    </Router>
  ),
  root
);
