/* @refresh reload */
import { Router } from '@solidjs/router';
import { render } from 'solid-js/web';
import App from './App';
import './styles/index.css';

const root = document.getElementById('root');

if (!root) {
  throw new Error('Root element not found');
}

render(
  () => (
    <Router>
      <App />
    </Router>
  ),
  root
);
