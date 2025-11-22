########################
# Main domain + www (HTTPS)
########################
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name wushutournaments.com www.wushutournaments.com;

    root /var/www/wushutournaments.com;
    index index.html;

    # SSL config (Certbot)
    ssl_certificate /etc/letsencrypt/live/wushutournaments.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/wushutournaments.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # ---- scoring app under /scoring ----
    # IMPORTANT: this block must come BEFORE the generic "/" block
    location /scoring/ {
        # Files are under /var/www/wushutournaments.com/scoring
        # For example: /scoring/index.html, /scoring/assets/...
        try_files $uri $uri/ /scoring/index.html;
    }

    # ---- main marketing site at root ----
    location / {
        try_files $uri $uri/ =404;
    }

    # ---- API for scoring app when accessed via /scoring/api ----
    location /scoring/api/ {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # ---- WebSocket / Socket.IO ----
    # Socket.IO client connects to /socket.io from the same origin
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
# scoring.wushutournaments.com (HTTPS → redirect to /scoring)
########################
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name scoring.wushutournaments.com;

    # Use same certificate
    ssl_certificate /etc/letsencrypt/live/wushutournaments.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letzenscrypt/live/wushutournaments.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # Redirect scoring subdomain to main /scoring path
    return 301 https://wushutournaments.com/scoring$request_uri;
}

########################
# HTTP → HTTPS redirects
########################

# Main domain + www (HTTP)
server {
    listen 80;
    listen [::]:80;
    server_name wushutournaments.com www.wushutournaments.com;

    return 301 https://$host$request_uri;
}

# scoring.wushutournaments.com (HTTP)
server {
    listen 80;
    listen [::]:80;
    server_name scoring.wushutournaments.com;

    return 301 https://wushutournaments.com/scoring$request_uri;
}
