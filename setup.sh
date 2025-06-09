#!/bin/bash

set -e

echo "[+] Instalando dependências do sistema..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv nginx

echo "[+] Criando ambiente virtual..."
python3 -m venv venv
source venv/bin/activate

echo "[+] Instalando dependências do projeto..."
pip install -r requirements.txt

echo "[+] Criando serviço systemd para gunicorn..."
SERVICE_FILE=/etc/systemd/system/todo-app.service

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Gunicorn service for todo-app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/todo-app
ExecStart=/home/ubuntu/todo-app/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Ativando e iniciando o serviço..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable todo-app
sudo systemctl restart todo-app

echo "[+] Configurando NGINX..."
NGINX_SITE=/etc/nginx/sites-available/todo-app

sudo tee $NGINX_SITE > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

sudo ln -sf $NGINX_SITE /etc/nginx/sites-enabled/todo-app
sudo rm -f /etc/nginx/sites-enabled/default

echo "[+] Testando configuração do NGINX..."
sudo nginx -t

echo "[+] Reiniciando NGINX..."
sudo systemctl reload nginx

echo "[✓] Deploy concluído com sucesso! Acesse via navegador no IP do servidor."

