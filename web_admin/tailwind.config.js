/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        'b-purple': {
          DEFAULT: '#8B5CF6',
          dark: '#7C3AED',
          light: '#A78BFA',
        },
        'b-gold': {
          DEFAULT: '#F59E0B',
          light: '#FBBF24',
          dark: '#D97706',
        },
        'b-black': '#0A0A0F',
        'b-surface': {
          DEFAULT: '#0A0A0F',
          elevated: '#161622',
          muted: '#1E1E2E',
          hover: '#252538',
        },
        'b-on-surface': {
          DEFAULT: '#FFFFFF',
          muted: '#9CA3AF',
          secondary: '#6B7280',
        },
        'b-border': 'rgba(139, 92, 246, 0.15)',
        'b-live': '#FF1A1A',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
