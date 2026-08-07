#!/bin/bash

CRED_FILE="/root/creds"
proxyfile="/root/r4teltcp.ovpn"

if [ ! -f "$CRED_FILE" ]; then
        echo -e "[!] Error: File $CRED_FILE no found!"
        exit 1
fi

if ! command -v sshpass &> /dev/null; then
    echo -e "[!] Error: Нет утилиты sshpass Установить командой: apt install sshpass"
    exit 1
fi

IFS=":" read -r USER PASS HOST < "$CRED_FILE"

USER=$(echo "$USER" | tr -d '\r ' )
PASS=$(echo "$PASS" | tr -d '\r ' )
HOST=$(echo "$HOST" | tr -d '\r ' )


if [ -z "$USER" ] || [ -z "$PASS" ] || [ -z "$HOST" ]; then
    echo -e "[!] Error: не верный формат даннх в файле $CRED_FILE. Нужный формат user:pass:host"
    exit 1
fi

echo "Запуск SSH-тунеля в фоне для $USER@$HOST..."
sshpass -p "$PASS" ssh -D 5252 -Nn "$USER@$HOST" &

# Запись в /etc/proxychains4 --> socks5 127.0.0.1 5252
if [ $? -eq 0 ]; then
    echo -e "[*] Тунель успешно запущен в фоновом режиме!"
    echo -e "[*] Proxychains4 start"
    proxychains4 openvpn $proxyfile
else
        echo -e "[!] Error!"
fi
