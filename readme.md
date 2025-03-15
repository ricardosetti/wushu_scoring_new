

# Wushu Scoring System (Version 1.0)

The Wushu Scoring System is a web application designed to manage and score Wushu competitions. It includes features for managing schools, participants, and divisions, as well as real-time scoring by judges, a head judge panel for publishing scores, a scoreboard for displaying participant scores, and a leaderboard for ranking participants by division.

## Features
- **Admin Management**: Manage schools, participants, and divisions via an admin panel.
- **Division-Based Competitions**: Set an active division to organize scoring and rankings.
- **Real-Time Scoring**: Judges can submit scores, with real-time updates via Socket.IO.
- **Head Judge Panel**: Start divisions, select active participants, calculate final scores, and publish scores.
- **Scoreboard**: Displays the active participant’s scores, deductions, and final score for the active division.
- **Leaderboard**: Shows ranked participants by final score for the active division.
- **Responsive Design**: Built with Tailwind CSS for a responsive UI across devices.

## Tech Stack
- **Backend**: Node.js, Express, Socket.IO, PostgreSQL
- **Frontend**: Vue.js 3, Vue Router, Tailwind CSS, Vite
- **Database**: PostgreSQL
- **Deployment**: Raspberry Pi (production)

## Prerequisites
Before setting up the project, ensure you have the following installed:
- **Node.js** (v20.x recommended; v22.x may have compatibility issues)
- **npm** (v10.x or later)
- **PostgreSQL** (v14 or later)
- **Git** (for cloning the repository)
- **pm2** (for production deployment on Raspberry Pi)

## Project Structure
 
wushu-scoring/
├── wushu_backend/         # Backend (Node.js/Express)
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── index.js
│   │   └── ...
│   ├── package.json
│   └── ...
├── wush/                  # Frontend (Vue.js)
│   ├── src/
│   │   ├── views/
│   │   ├── router/
│   │   ├── assets/
│   │   ├── main.js
│   │   └── ...
│   ├── package.json
│   ├── tailwind.config.js
│   └── ...
├── db.sql                 # Database schema
└── README.md
 

## Setup Instructions

### 1. Development Environment
Follow these steps to set up the project for development on your local machine.

#### Clone the Repository
 
git clone <your-repository-url>
cd wushu-scoring
 

#### Set Up the Database
1. Ensure PostgreSQL is running on your machine.
2. Create a database for the project:
    
   psql -U postgres
   CREATE DATABASE wushu_scoring;
   \q
    
3. Import the database schema:
    
   psql -U postgres -d wushu_scoring -f db.sql
    
4. Verify the tables (`schools`, `participants`, `divisions`, `scores`, `published_scores`, etc.) are created:
    
   psql -U postgres -d wushu_scoring -c "\dt"
    

#### Set Up the Backend
1. Navigate to the backend directory:
    
   cd wushu_backend
    
2. Install dependencies:
    
   npm install
    
3. Create a `.env` file in `wushu_backend/` with the following:
    
   PORT=5000
   DATABASE_URL=postgres://postgres:your_password@localhost:5432/wushu_scoring
    
   Replace `your_password` with your PostgreSQL password.
4. Start the backend in development mode:
    
   npm run dev
    
   The backend should be running on `http://localhost:5000`.

#### Set Up the Frontend
1. Navigate to the frontend directory:
    
   cd ../wush
    
2. Install dependencies:
    
   npm install
    
3. Create a `.env` file in `wush/` with the following:
    
   VITE_SERVER_HOST=localhost
   VITE_SERVER_PORT=5000
    
4. Start the frontend in development mode:
    
   npm run dev
    
   The frontend should be running on `http://localhost:5173`.

#### Access the Application
- **Head Judge Panel**: `http://localhost:5173/head-judge`
- **Scoreboard**: `http://localhost:5173/scoreboard`
- **Leaderboard**: `http://localhost:5173/leaderboard`
- **Admin Pages**:
  - Schools: `http://localhost:5173/admin/schools`
  - Participants: `http://localhost:5173/admin/participants`
  - Divisions: `http://localhost:5173/admin/divisions`
- **Judge Panels**:
  - Judge A1: `http://localhost:5173/judge-a1`
  - Judge A2: `http://localhost:5173/judge-a2`
  - Judge B1: `http://localhost:5173/judge-b1`
  - Judge B2: `http://localhost:5173/judge-b2`

### 2. Production Environment (Raspberry Pi)
Follow these steps to deploy the application on a Raspberry Pi for production.

#### Prepare the Raspberry Pi
1. Update the system:
    
   sudo apt update && sudo apt upgrade -y
    
2. Install Node.js and npm (if not already installed):
    
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt install -y nodejs
   node -v  # Should show v20.x
   npm -v   # Should show v10.x or later
    
3. Install PostgreSQL:
    
   sudo apt install -y postgresql postgresql-contrib
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
    
4. Install `pm2` for process management:
    
   sudo npm install -g pm2
    

#### Set Up the Database
1. Create a PostgreSQL user and database:
    
   sudo -u postgres psql
   CREATE USER wushu WITH PASSWORD 'your_secure_password';
   CREATE DATABASE wushu_scoring OWNER wushu;
   \q
    
2. Copy `db.sql` to the Raspberry Pi (e.g., via SCP):
    
   scp db.sql pi@192.168.1.16:/home/pi/
    
   Replace `192.168.1.16` with your Raspberry Pi’s IP address.
3. Import the database schema:
    
   psql -U wushu -d wushu_scoring -f /home/pi/db.sql
    
4. Verify the tables:
    
   psql -U wushu -d wushu_scoring -c "\dt"
    

#### Deploy the Backend
1. Copy the backend files to the Raspberry Pi:
    
   scp -r wushu_backend pi@192.168.1.16:/var/www/wushu_scoring/
    
2. SSH into the Raspberry Pi:
    
   ssh pi@192.168.1.16
    
3. Install backend dependencies:
    
   cd /var/www/wushu_scoring/wushu_backend
   npm install
    
4. Create a `.env` file in `/var/www/wushu_scoring/wushu_backend/`:
    
   PORT=5000
   DATABASE_URL=postgres://wushu:your_secure_password@localhost:5432/wushu_scoring
    
   Replace `your_secure_password` with the password set earlier.
5. Start the backend with `pm2`:
    
   pm2 start npm --name "wushu_backend" -- start
   pm2 save
   pm2 startup
    
   Follow the output instructions to ensure `pm2` starts on boot.

#### Deploy the Frontend
1. Build the frontend on your local machine:
    
   cd wushu_scoring_new-1/wush
   npm run build
    
   This generates a `dist/` folder with the production-ready files.
2. Copy the built files to the Raspberry Pi:
    
   scp -r dist/* pi@192.168.1.16:/var/www/wushu_scoring/frontend/
    
3. Install a web server (e.g., Nginx) on the Raspberry Pi:
    
   sudo apt install -y nginx
    
4. Configure Nginx to serve the frontend:
   - Create a configuration file:
      
     sudo nano /etc/nginx/sites-available/wushu_scoring
      
   - Add the following configuration:
      
     server {
         listen 80;
         server_name 192.168.1.16;

         location / {
             root /var/www/wushu_scoring/frontend;
             index index.html;
             try_files $uri $uri/ /index.html;
         }

         location /api/ {
             proxy_pass http://localhost:5000/;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_set_header X-Forwarded-Proto $scheme;
         }

         location /socket.io/ {
             proxy_pass http://localhost:5000/socket.io/;
             proxy_http_version 1.1;
             proxy_set_header Upgrade $http_upgrade;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host $host;
         }
     }
      
   - Enable the configuration:
      
     sudo ln -s /etc/nginx/sites-available/wushu_scoring /etc/nginx/sites-enabled/
     sudo nginx -t  # Test configuration
     sudo systemctl restart nginx
      

#### Access the Application
- Access the application at `http://192.168.1.16` (replace with your Raspberry Pi’s IP).
- Ensure the backend is running (`pm2 logs wushu_backend`).

## Usage
1. **Admin Setup**:
   - Add schools, participants, and divisions via the admin pages.
   - Assign participants to divisions.
2. **Head Judge**:
   - Start a division from the Head Judge panel.
   - Select an active participant and turn on scoring for judges.
   - Calculate and publish final scores.
3. **Judges**:
   - Submit scores for the active participant in the active division.
4. **Scoreboard**:
   - View the active participant’s scores for the active division.
5. **Leaderboard**:
   - View ranked participants for the active division, sorted by final score.

## Troubleshooting
- **Backend Not Starting**:
  - Check `pm2 logs wushu_backend` for errors.
  - Ensure `DATABASE_URL` in `.env` is correct.
- **Frontend Not Loading**:
  - Verify Nginx is running (`sudo systemctl status nginx`).
  - Check Nginx logs (`sudo tail -f /var/log/nginx/error.log`).
- **Scores Not Showing**:
  - Ensure an active division is set.
  - Verify scores are published for the active division.
- **Real-Time Updates Not Working**:
  - Confirm Socket.IO connection (`http://<your-ip>:5000/socket.io`).

## Contributing
To contribute to this project:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m "Add YourFeature"`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

## License
This project is licensed under the MIT License.

## Contact
For questions or support, please contact [ricardo@8bitdesk.com].

