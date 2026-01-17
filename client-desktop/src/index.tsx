/* @refresh reload */
import { Route, Router } from '@solidjs/router';
import { render } from 'solid-js/web';
import App, { AuthProvider, useAuth } from './App';
import './styles/index.css';

// Pages
import Chat from './pages/Chat';
import Login from './pages/Login';
import Register from './pages/Register';
import Settings from './pages/Settings';

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
    <Router root={(props) => <AuthProvider><App>{props.children}</App></AuthProvider>}>
      <Route path="/" component={Chat} />
      <Route path="/chat/:conversationId?" component={Chat} />
      <Route path="/settings" component={Settings} />
      <Route path="/login" component={LoginPage} />
      <Route path="/register" component={RegisterPage} />
    </Router>
  ),
  root
);
