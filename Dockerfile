FROM n8nio/n8n:latest

USER root

COPY docker-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

RUN mkdir -p /home/node/.n8n \
  && chown -R node:node /home/node/.n8n \
  && chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/railway-entrypoint.sh"]
CMD ["start"]
