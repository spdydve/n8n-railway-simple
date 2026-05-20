FROM n8nio/n8n:latest

USER root

RUN mkdir -p /home/node/.n8n

CMD ["sh", "-c", "chown -R node:node /home/node/.n8n && su node -c 'n8n start'"]
