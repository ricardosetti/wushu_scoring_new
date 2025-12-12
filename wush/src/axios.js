import axios from 'axios';

const instance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'http://localhost:5000',
});

instance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

instance.interceptors.response.use(
  (response) => response,
  (error) => {
    // Check if the error came from a Login request
    // If so, we DON'T want to redirect, we want to show the error message on screen
    const isLoginRequest = error.config && error.config.url && error.config.url.includes('/auth/login');

    if (error.response && error.response.status === 401 && !isLoginRequest) {
      console.log('Session expired, redirecting to login...');
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      // Redirect to the generic login page
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default instance;