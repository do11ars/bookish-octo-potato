FROM cloudflare/cloudflared:latest AS cloudflared-bin

FROM vaultwarden/server:latest

RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

COPY --from=cloudflared-bin /usr/local/bin/cloudflared /usr/local/bin/cloudflared

RUN mkdir -p /var/log/supervisor
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root

[program:vaultwarden]
command=/vaultwarden
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:cloudflared]
command=cloudflared access tcp --hostname ://domain.com --url localhost:3306
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
