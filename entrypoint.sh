#!/usr/bin/env bash



# 设置 nginx 伪装站
rm -rf /usr/share/nginx/*
wget https://github.com/Jimyarkw/backFo/raw/main/mikutap.zip -O /usr/share/nginx/mikutap.zip
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip



# 如果有设置哪吒探针三个变量,会安装。如果不填或者不全,则不会安装
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY}

# 启用 Argo，并输出节点日志
cloudflared tunnel --url http://localhost:80 --no-autoupdate > argo.log 2>&1 &
sleep 5 && argo_url=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")

vmlink=$(echo -e '\x76\x6d\x65\x73\x73')://$(echo -n "{\"v\":\"2\",\"ps\":\"Argo_xray_vmess\",\"add\":\"$argo_url\",\"port\":\"443\",\"id\":\"8192f723-6b17-4edc-a109-ff21cdec461b\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$argo_url\",\"path\":\"/vmess?ed=2048\",\"tls\":\"tls\"}" | base64 -w 0)
vllink=$(echo -e '\x76\x6c\x65\x73\x73')"://8192f723-6b17-4edc-a109-ff21cdec461b@"$argo_url":443?encryption=none&security=tls&type=ws&host="$argo_url"&path=/vless?ed=2048#Argo_xray_vless"
trlink=$(echo -e '\x74\x72\x6f\x6a\x61\x6e')"://8192f723-6b17-4edc-a109-ff21cdec461b@"$argo_url":443?security=tls&type=ws&host="$argo_url"&path=/trojan?ed2048#Argo_xray_trojan"

qrencode -o /usr/share/nginx/html/M8192f723-6b17-4edc-a109-ff21cdec461b.png $vmlink
qrencode -o /usr/share/nginx/html/L8192f723-6b17-4edc-a109-ff21cdec461b.png $vllink
qrencode -o /usr/share/nginx/html/T8192f723-6b17-4edc-a109-ff21cdec461b.png $trlink

cat > /usr/share/nginx/html/8192f723-6b17-4edc-a109-ff21cdec461b.html<<-EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Argo-xray-paas</title>
    <style type="text/css">
        body {
            font-family: Geneva, Arial, Helvetica, san-serif;
        }

        div {
            margin: 0 auto;
            text-align: left;
            white-space: pre-wrap;
            word-break: break-all;
            max-width: 80%;
            margin-bottom: 10px;
        }
    </style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
    <div>
        <font color="#009900"><b>VMESS协议链接：</b></font>
    </div>
    <div>$vmlink</div>
    <div>
        <font color="#009900"><b>VMESS协议二维码：</b></font>
    </div>
    <div><img src="/M8192f723-6b17-4edc-a109-ff21cdec461b.png"></div>
    <div>
        <font color="#009900"><b>VLESS协议链接：</b></font>
    </div>
    <div>$vllink</div>
    <div>
        <font color="#009900"><b>VLESS协议二维码：</b></font>
    </div>
    <div><img src="/L8192f723-6b17-4edc-a109-ff21cdec461b.png"></div>
    <div>
        <font color="#009900"><b>TROJAN协议链接：</b></font>
    </div>
    <div>$trlink</div>
    <div>
        <font color="#009900"><b>TROJAN协议二维码：</b></font>
    </div>
    <div><img src="/T8192f723-6b17-4edc-a109-ff21cdec461b.png"></div>
    <div>
        <font color="#009900"><b>SS协议明文：</b></font>
    </div>
    <div>服务器地址：$argo_url</div>
    <div>端口：443</div>
    <div>密码：8192f723-6b17-4edc-a109-ff21cdec461b</div>
    <div>加密方式：chacha20-ietf-poly1305</div>
    <div>传输协议：ws</div>
    <div>host：$argo_url</div>
    <div>path路径：/ssss?ed=2048</div>
    <div>TLS：开启</div>
</body>
</html>
EOF
nginx

./websist