#!/usr/bin/env bash



# 设置 nginx 伪装站
rm -rf /usr/share/nginx/*
wget https://raw.githubusercontent.com/numia090/ikhugip/main/fodder/blog/unable/html5.zip -O /usr/share/nginx/mikutap.zip
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip



# 如果有设置哪吒探针三个变量,会安装。如果不填或者不全,则不会安装
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY}

# 启用 Argo，并输出节点日志
cloudflared tunnel --url http://localhost:80 --no-autoupdate > argo.log 2>&1 &
sleep 5 && argo_url=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")

vmlink=$(echo -e '\x76\x6d\x65\x73\x73')://$(echo -n "{\"v\":\"2\",\"ps\":\"Argo_xray_vmess\",\"add\":\"$argo_url\",\"port\":\"443\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$argo_url\",\"path\":\"$VMESS_WSPATH?ed=2048\",\"tls\":\"tls\"}" | base64 -w 0)
vllink=$(echo -e '\x76\x6c\x65\x73\x73')"://"$UUID"@"$argo_url":443?encryption=none&security=tls&type=ws&host="$argo_url"&path="$VLESS_WSPATH"?ed=2048#Argo_xray_vless"
trlink=$(echo -e '\x74\x72\x6f\x6a\x61\x6e')"://"$UUID"@"$argo_url":443?security=tls&type=ws&host="$argo_url"&path="$TROJAN_WSPATH"?ed2048#Argo_xray_trojan"
echo $vmlink
echo $vllink
nginx

./websist