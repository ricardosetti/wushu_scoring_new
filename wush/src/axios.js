import axios from 'axios';

const instance = axios.create({
  baseURL: `http://${import.meta.env.VITE_SERVER_HOST}:${import.meta.env.VITE_SERVER_PORT}`,
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
    if (error.response && error.response.status === 401) {
      console.log('Credentials expired, redirecting to login...');
      // Clear token and role
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      // Redirect to login
      window.location.href = '/login'; // Use window.location.href since useRouter isn't available here
    }
    return Promise.reject(error);
  }
);

export default instance;