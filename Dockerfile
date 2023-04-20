FROM nginx:latest
EXPOSE 80
WORKDIR /app
USER root

COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json ./
COPY entrypoint.sh ./

RUN apt-get update && apt-get install -y wget unzip qrencode iproute2 systemctl && \
    wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared.deb && \
    rm -f cloudflared.deb && \
    wget -O temp.zip https://raw.githubusercontent.com/numia090/paas/master/web.zip && \
    unzip temp.zip  websist && \
    rm -f temp.zip && \
    chmod -v 755 websist entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]