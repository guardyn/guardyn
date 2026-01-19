/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        guardyn: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
          950: '#052e16',
        },
        // Chat backgrounds (pastel)
        chat: {
          light: '#f5fdf8',
          'light-pattern': '#ecfdf3',
          dark: '#0d1f12',
          'dark-pattern': '#0f2616',
        },
        // Sidebar backgrounds
        sidebar: {
          light: '#fafafa',
          dark: '#111111',
        },
      },
      fontFamily: {
        sans: ["'Inter Variable'", "'Inter'", 'system-ui', '-apple-system', 'BlinkMacSystemFont', "'Segoe UI'", 'Roboto', 'sans-serif'],
        mono: ["'JetBrains Mono'", "'Fira Code'", "'SF Mono'", 'Monaco', 'Consolas', 'monospace'],
      },
      boxShadow: {
        // Neumorphic shadows - Light mode
        'neumorphic': '6px 6px 12px #d1d9e6, -6px -6px 12px #ffffff',
        'neumorphic-sm': '3px 3px 6px #d1d9e6, -3px -3px 6px #ffffff',
        'neumorphic-pressed': 'inset 4px 4px 8px #d1d9e6, inset -4px -4px 8px #ffffff',
        // Neumorphic shadows - Dark mode
        'neumorphic-dark': '6px 6px 12px #0a0a0a, -6px -6px 12px #1e1e1e',
        'neumorphic-dark-sm': '3px 3px 6px #0a0a0a, -3px -3px 6px #1e1e1e',
        'neumorphic-dark-pressed': 'inset 4px 4px 8px #0a0a0a, inset -4px -4px 8px #1e1e1e',
        // Glow effects
        'glow-primary': '0 0 16px rgba(34, 197, 94, 0.4)',
        'glow-primary-sm': '0 0 8px rgba(34, 197, 94, 0.3)',
        'glow-error': '0 0 16px rgba(239, 68, 68, 0.4)',
      },
      backdropBlur: {
        xs: '2px',
      },
      animation: {
        'fade-in': 'fadeIn 0.2s ease-out',
        'slide-in': 'slideIn 0.2s ease-out',
        'scale-in': 'scaleIn 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        'pulse-slow': 'pulse-slow 3s ease-in-out infinite',
        'float': 'float 20s ease-in-out infinite',
      },
    },
  },
  plugins: [
    // Glassmorphism utilities
    function({ addUtilities }) {
      addUtilities({
        '.glass-card': {
          background: 'rgba(255, 255, 255, 0.7)',
          backdropFilter: 'blur(20px)',
          '-webkit-backdrop-filter': 'blur(20px)',
          border: '1px solid rgba(255, 255, 255, 0.2)',
        },
        '.glass-card-dark': {
          background: 'rgba(17, 24, 39, 0.75)',
          backdropFilter: 'blur(20px)',
          '-webkit-backdrop-filter': 'blur(20px)',
          border: '1px solid rgba(255, 255, 255, 0.1)',
        },
        '.neumorphic-btn': {
          background: '#f0f0f3',
          boxShadow: '6px 6px 12px #d1d9e6, -6px -6px 12px #ffffff',
          transition: 'all 0.2s ease-out',
        },
        '.neumorphic-btn:hover': {
          background: '#e8e8eb',
          boxShadow: '3px 3px 6px #d1d9e6, -3px -3px 6px #ffffff',
        },
        '.neumorphic-btn:active': {
          boxShadow: 'inset 4px 4px 8px #d1d9e6, inset -4px -4px 8px #ffffff',
        },
        '.dark .neumorphic-btn': {
          background: '#141414',
          boxShadow: '6px 6px 12px #0a0a0a, -6px -6px 12px #1e1e1e',
        },
        '.dark .neumorphic-btn:hover': {
          background: '#1a1a1a',
          boxShadow: '3px 3px 6px #0a0a0a, -3px -3px 6px #1e1e1e',
        },
        '.dark .neumorphic-btn:active': {
          boxShadow: 'inset 4px 4px 8px #0a0a0a, inset -4px -4px 8px #1e1e1e',
        },
      })
    },
  ],
}
