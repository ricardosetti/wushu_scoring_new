export default {
  content: [
    './src/**/*.{vue,js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        darkgray: '#374151',
        'darkgray-dark': '#4A5568',
        primary: '#1E40AF', // Use 'primary' to match your components
        red: '#EF4444',
      },
    },
  },
  plugins: [],
};