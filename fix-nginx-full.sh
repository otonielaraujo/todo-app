#!/bin/bash

CONF="/etc/nginx/nginx.conf"

echo "[+] Corrigindo includes inválidos em $CONF..."

# Remove qualquer linha com 'include /etc/nginx/sites-enabled/todo'
sudo sed -i '/include \/etc\/nginx\/sites-enabled\/todo;/d' "$CONF"

# Verifica se a linha correta já existe
if ! grep -q 'include /etc/nginx/sites-enabled/\*;' "$CONF"; then
    echo "[+] Adicionando linha correta no bloco http { }..."

    # Insere logo após a linha que contém 'http {'
    sudo sed -i '/http {/a\    include /etc/nginx/sites-enabled/*;' "$CONF"
fi

echo "[+] Testando configuração do NGINX..."
if sudo nginx -t; then
    echo "[✓] Configuração válida. Reiniciando NGINX..."
    sudo systemctl restart nginx
    echo "[✓] NGINX reiniciado com sucesso."
else
    echo "[✗] Erro na configuração do NGINX. Verifique manualmente:"
    sudo nginx -t
    exit 1
fi

echo "[✓] Finalizado com sucesso."

