<template>
  <div class="container mx-auto p-4">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-2xl font-bold text-gray-800">User Administration</h2>
      <button 
        @click="openAddModal" 
        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded shadow"
      >
        + Add User
      </button>
    </div>

    <!-- User List -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="p-4 border-b">
        <input 
          v-model="search" 
          placeholder="Search by name, email, or role..." 
          class="w-full border p-2 rounded"
        />
      </div>
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">User</th>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Role</th>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">
              <div class="font-bold text-gray-900">{{ user.first_name }} {{ user.last_name }}</div>
              <div class="text-xs text-gray-500">{{ user.email }}</div>
            </td>
            <td class="px-6 py-4 text-sm">
              <span class="px-2 py-1 rounded text-xs font-bold uppercase" :class="getRoleBadge(user.role)">
                {{ user.role }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm">
              <span v-if="user.is_verified" class="text-green-600 font-bold">Verified</span>
              <span v-else class="text-gray-400">Unverified</span>
            </td>
            <td class="px-6 py-4 text-right space-x-2">
              <button @click="openEditModal(user)" class="text-blue-600 hover:text-blue-800 text-xs font-bold">Edit</button>
              <button @click="openPasswordModal(user)" class="text-orange-600 hover:text-orange-800 text-xs font-bold">Reset Pass</button>
              <button @click="deleteUser(user)" class="text-red-600 hover:text-red-800 text-xs font-bold">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add/Edit User Modal -->
    <div v-if="showUserModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white p-6 rounded-lg shadow-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ editUserId ? 'Edit User' : 'Add User' }}</h3>
        <form @submit.prevent="submitUser" class="space-y-4">
          
          <!-- Identity -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">First Name *</label>
              <input v-model="form.first_name" required class="w-full border p-2 rounded" />
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Last Name *</label>
              <input v-model="form.last_name" required class="w-full border p-2 rounded" />
            </div>
          </div>

          <!-- Account -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Email *</label>
              <input v-model="form.email" type="email" required class="w-full border p-2 rounded" />
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Role *</label>
              <select v-model="form.role" class="w-full border p-2 rounded bg-white">
                <option value="participant">Participant</option>
                <option value="admin">Admin</option>
                <option value="judge_a">Judge A</option>
                <option value="judge_b">Judge B</option>
                <option value="head_judge">Head Judge</option>
              </select>
            </div>
          </div>

          <!-- Personal Details -->
          <div class="grid grid-cols-2 md:grid-cols-3 gap-4 bg-gray-50 p-3 rounded">
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Date of Birth</label>
              <input v-model="form.birthdate" type="date" class="w-full border p-2 rounded" />
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Gender</label>
              <select v-model="form.gender" class="w-full border p-2 rounded bg-white">
                <option value="">Select</option>
                <option value="M">Male</option>
                <option value="F">Female</option>
                <option value="O">Other</option>
              </select>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-700 mb-1">Phone</label>
              <input v-model="form.phone" class="w-full border p-2 rounded" />
            </div>
          </div>

          <!-- Address -->
          <div class="space-y-2 bg-gray-50 p-3 rounded">
            <h4 class="text-xs font-bold text-gray-500 uppercase">Address</h4>
            <div>
              <input v-model="form.street" placeholder="Street Address" class="w-full border p-2 rounded" />
            </div>
            <div class="grid grid-cols-2 gap-4">
              <input v-model="form.city" placeholder="City" class="w-full border p-2 rounded" />
              <input v-model="form.state" placeholder="State/Province" class="w-full border p-2 rounded" />
            </div>
            <div class="grid grid-cols-2 gap-4">
              <input v-model="form.zip_code" placeholder="Zip/Postal" class="w-full border p-2 rounded" />
              <select v-model="form.country" class="w-full border p-2 rounded bg-white">
                 <option value="">Select Country</option>
                 <option value="USA">USA</option>
                 <option value="CAN">Canada</option>
                 <option value="BRA">Brazil</option>
                 <option value="MEX">Mexico</option>
                 <option value="GBR">UK</option>
                 <option value="Other">Other</option>
              </select>
            </div>
          </div>

          <div v-if="!editUserId">
            <label class="block text-xs font-bold text-gray-700 mb-1">Initial Password *</label>
            <input v-model="form.password" type="password" required class="w-full border p-2 rounded" />
          </div>

          <div class="flex items-center space-x-2 pt-2">
            <input type="checkbox" v-model="form.is_verified" id="chkVerified" class="h-4 w-4">
            <label for="chkVerified" class="text-sm text-gray-700 font-medium">Account Verified?</label>
          </div>

          <div class="mt-6 flex justify-end space-x-3 pt-4 border-t">
            <button type="button" @click="showUserModal = false" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
            <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded shadow hover:bg-blue-700">Save User</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Reset Password Modal -->
    <div v-if="showPasswordModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg w-full max-w-sm">
        <h3 class="text-lg font-bold mb-4">Reset Password for {{ selectedUser?.first_name }}</h3>
        <input v-model="newPassword" type="password" placeholder="New Password" class="w-full border p-2 rounded mb-4" />
        <div class="flex justify-end space-x-2">
          <button @click="showPasswordModal = false" class="px-4 py-2 text-gray-600">Cancel</button>
          <button @click="submitPasswordReset" class="px-4 py-2 bg-orange-600 text-white rounded">Update Password</button>
        </div>
      </div>
    </div>
    
    <div class="mt-6">
      <button @click="$router.push('/admin')" class="text-gray-500 hover:text-gray-800">← Back to Dashboard</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from '../axios';

const users = ref([]);
const search = ref('');
const loading = ref(true);

const showUserModal = ref(false);
const showPasswordModal = ref(false);
const editUserId = ref(null);
const selectedUser = ref(null);
const newPassword = ref('');

// Initial Form State
const defaultForm = {
  first_name: '', last_name: '', email: '', password: '', role: 'participant', is_verified: true,
  birthdate: '', gender: '', phone: '',
  street: '', city: '', state: '', zip_code: '', country: ''
};
const form = ref({ ...defaultForm });

const filteredUsers = computed(() => {
  if (!search.value) return users.value;
  const s = search.value.toLowerCase();
  return users.value.filter(u => 
    (u.first_name + ' ' + u.last_name).toLowerCase().includes(s) || 
    u.email.toLowerCase().includes(s) ||
    u.role.includes(s)
  );
});

const fetchUsers = async () => {
  loading.value = true;
  try {
    const res = await axios.get('/users');
    users.value = res.data;
  } catch (e) { console.error(e); } 
  finally { loading.value = false; }
};

const openAddModal = () => {
  editUserId.value = null;
  form.value = { ...defaultForm };
  showUserModal.value = true;
};

const openEditModal = (user) => {
  editUserId.value = user.id;
  // Clone user data to form
  form.value = { ...user, password: '' }; 
  // Format Date for Input
  if (form.value.birthdate) {
    form.value.birthdate = form.value.birthdate.split('T')[0];
  }
  showUserModal.value = true;
};

const submitUser = async () => {
  try {
    if (editUserId.value) {
      const res = await axios.put(`/users/${editUserId.value}`, form.value);
      const idx = users.value.findIndex(u => u.id === editUserId.value);
      if (idx !== -1) users.value[idx] = { ...users.value[idx], ...res.data };
    } else {
      const res = await axios.post('/users', form.value);
      users.value.unshift(res.data);
    }
    showUserModal.value = false;
  } catch (e) {
    alert("Error saving user: " + (e.response?.data?.error || e.message));
  }
};

const deleteUser = async (user) => {
  if (!confirm(`Delete user ${user.email}? This cannot be undone.`)) return;
  try {
    await axios.delete(`/users/${user.id}`);
    users.value = users.value.filter(u => u.id !== user.id);
  } catch (e) {
    alert("Failed to delete user.");
  }
};

const openPasswordModal = (user) => {
  selectedUser.value = user;
  newPassword.value = '';
  showPasswordModal.value = true;
};

const submitPasswordReset = async () => {
  if (!newPassword.value) return alert("Enter a password");
  try {
    await axios.put(`/users/${selectedUser.value.id}/reset-password`, { newPassword: newPassword.value });
    alert("Password updated");
    showPasswordModal.value = false;
  } catch (e) {
    alert("Failed to reset password");
  }
};

const getRoleBadge = (role) => {
  if (role === 'admin') return 'bg-purple-100 text-purple-800';
  if (role === 'head_judge') return 'bg-red-100 text-red-800';
  if (role.startsWith('judge')) return 'bg-yellow-100 text-yellow-800';
  return 'bg-blue-100 text-blue-800';
};

onMounted(fetchUsers);
</script>