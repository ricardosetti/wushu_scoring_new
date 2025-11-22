# Wushu Scoring System (Version 1.0)

The Wushu Scoring System is a web application designed to manage and score Wushu competitions. It includes features for managing schools, participants, and divisions, as well as real-time scoring by judges, a head judge panel for publishing scores, a scoreboard for displaying participant scores, and a leaderboard for ranking participants by division.

## Features
- **Admin Management**: Manage schools, participants, and divisions via an admin panel.
- **Division-Based Competitions**: Set an active division to organize scoring and rankings.
- **Real-Time Scoring**: Judges can submit scores, with real-time updates via Socket.IO.
- **Head Judge Panel**: Start divisions, select active participants, calculate final scores, and publish scores.
- **Scoreboard**: Displays the active participant’s scores, deductions, and final score for the active division. Accessible to both authenticated and unauthenticated users.
- **Leaderboard**: Shows ranked participants by final score for the active division. Accessible to both authenticated and unauthenticated users.
- **Role-Based Access Control**:
  - Admin users have access to all routes (Admin, Head Judge, Judge A1/A2/B1/B2, Scoreboard, Leaderboard).
  - Head Judge and Judges (A1, A2, B1, B2) have access to their respective panels, Scoreboard, and Leaderboard.
  - Unauthenticated users can access Scoreboard and Leaderboard.
- **Token Expiration Handling**: Automatically redirects users to the login page when their authentication token expires.
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


# Wushu Scoring System – Full Dev & Prod Setup

This project contains a complete Node.js + PostgreSQL backend and a Vite + Vue frontend
for managing Wushu tournament scoring.  
This document explains **how to run the system in development**, and **how to deploy to production** using:

- Ubuntu on DigitalOcean
- Nginx reverse proxy
- PM2 process manager
- Let’s Encrypt SSL
- Domain routing for:

  - https://wushutournaments.com (marketing site)
  - https://wushutournaments.com/scoring (scoring system)
  - https://scoring.wushutournaments.com → redirects to `/scoring`

---

# 📁 Project Structure

wushu-scoring/
│
├── wushu-backend/ # Node + Express + Socket.IO + PostgreSQL
│ ├── src/
│ │ ├── server.js
│ │ ├── routes/
│ │ ├── controllers/
│ │ └── ...
│ ├── package.json
│ └── .env
│
└── wush/ # Frontend (Vue + Vite)
├── src/
├── index.html
├── vite.config.js
├── .env
├── .env.production
└── package.json

---

# 🧪 DEVELOPMENT SETUP (LOCAL)

## 1. Backend: `.env` file (dev)

Located at: `wushu-backend/.env`
PGUSER=wushu
PGHOST=localhost
PGDATABASE=wushu
PGPASSWORD=yourpassword
PGPORT=5432

PORT=5000
FRONTEND_ORIGIN=http://localhost:5173

JWT_SECRET=your_secret
REGISTRATION_BASE_URL=http://localhost:5173/register

## 2. Run backend (dev)

cd wushu-backend
npm install
node src/server.js

Backend runs at:
http://localhost:5000

Socket.IO also connects here.

---

## 3. Frontend: `.env` (dev)

Located at: `wush/.env`

VITE_API_BASE=http://localhost:5000
VITE_SOCKET_URL=http://localhost:5000

## 4. Run frontend (dev)

cd wush
npm install
npm run dev

Frontend runs at:
http://localhost:5173

Dev environment supports:

- Full API communication
- Socket.IO updates
- Authentication
- All real-time scoring updates

---

# 🚀 PRODUCTION DEPLOYMENT

## 1. Create directories on the server
sudo mkdir -p /var/www/wushutournaments.com
sudo mkdir -p /var/www/wushutournaments.com/scoring
sudo chown -R $USER:$USER /var/www/wushutournaments.com

Your static marketing site goes under:
/var/www/wushutournaments.com

Your scoring SPA goes under:
/var/www/wushutournaments.com/scoring

---

# 🖥️ BACKEND DEPLOYMENT

Copy backend to server:
scp -r wushu-backend user@yourserver:/home/user/

Install deps:
cd wushu-backend
npm install

## Backend production `.env`
PGUSER=wushu
PGHOST=localhost
PGDATABASE=wushu
PGPASSWORD=yourpassword
PGPORT=5432

PORT=5000
FRONTEND_ORIGIN=https://wushutournaments.com

JWT_SECRET=your_secret
REGISTRATION_BASE_URL=https://wushutournaments.com/scoring/register

## Start backend with PM2
pm2 start src/server.js --name wushu-backend
pm2 save
pm2 startup

---

# 🎨 FRONTEND (PROD BUILD)

## Frontend `.env.production`

Located at: `wush/.env.production`
VITE_API_BASE=/scoring/api
VITE_SOCKET_URL=/socket.io

## Build with scoring base path
cd wush
npm run build -- --base=/scoring/

Copy dist to server:
cp -r dist/* /var/www/wushutournaments.com/scoring/


---

# 🌐 NGINX CONFIG (FINAL VERSION)

**Location:** `/etc/nginx/sites-available/wushutournaments.com`

```nginx
########################
# Main HTTPS server (wushutournaments.com)
########################
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name wushutournaments.com www.wushutournaments.com;

    root /var/www/wushutournaments.com;
    index index.html;

    ssl_certificate /etc/letsencrypt/live/wushutournaments.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/wushutournaments.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Frontend scoring app
    location /scoring/ {
        try_files $uri $uri/ /scoring/index.html;
    }

    # Marketing site
    location / {
        try_files $uri $uri/ =404;
    }

    # API proxy
    location /scoring/api/ {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Socket.IO WebSockets
    location /socket.io/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

########################
# scoring.wushutournaments.com redirects to main domain
########################
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name scoring.wushutournaments.com;

    ssl_certificate /etc/letsencrypt/live/wushutournaments.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/wushutournaments.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    return 301 https://wushutournaments.com/scoring$request_uri;
}

########################
# HTTP → HTTPS redirects
########################
server {
    listen 80;
    listen [::]:80;
    server_name wushutournaments.com www.wushutournaments.com;
    return 301 https://$host$request_uri;
}

server {
    listen 80;
    listen [::]:80;
    server_name scoring.wushutournaments.com;
    return 301 https://wushutournaments.com/scoring$request_uri;
}

Test & reload:
sudo nginx -t
sudo systemctl reload nginx

🔐 SSL Certificates (Let’s Encrypt)
To set up SSL:
sudo certbot --nginx -d wushutournaments.com -d www.wushutournaments.com -d scoring.wushutournaments.com
Certbot auto-renews.

Test renewal:
sudo certbot renew --dry-run

🔧 TROUBLESHOOTING
Blank screen
- Vite build was created without --base=/scoring/
- Missing index.html under /var/www/wushutournaments.com/scoring/

API 405 or 404
- Axios must use /scoring/api
- Backend must listen on port 5000
- Nginx must proxy /scoring/api → localhost:5000

Socket.IO not connecting
- Ensure /socket.io/ proxy exists in BOTH HTTPS blocks
- Frontend PRODUCTION must not use any localhost references
- Backend CORS origin must match: https://wushutournaments.com


## License
This project is licensed under the MIT License.

## Contact
For questions or support, please contact [ricardo@8bitdesk.com].

