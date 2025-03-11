# Use Alpine Linux as base image with Node.js
FROM node:18-alpine

# Set environment variables for n8n
ENV N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=admin \
    N8N_BASIC_AUTH_PASSWORD=admin123 \
    DB_TYPE=postgresdb \
    DB_POSTGRESDB_HOST=db \
    DB_POSTGRESDB_PORT=5432 \
    DB_POSTGRESDB_DATABASE=n8n \
    DB_POSTGRESDB_USER=n8n_user \
    DB_POSTGRESDB_PASSWORD=n8n_password \
    N8N_PROTOCOL=https \
    N8N_SSL_KEY=/home/node/.n8n/certificates/privkey.pem \
    N8N_SSL_CERT=/home/node/.n8n/certificates/fullchain.pem

# Switch to root user to install dependencies
USER root

# Install system dependencies
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv \
    bash \
    curl \
    openssl

# Create a virtual environment for Python packages
RUN python3 -m venv /opt/venv

# Activate virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip inside the virtual environment
RUN pip install --upgrade pip
RUN pip install instaloader
RUN pip install pillow

# Install n8n globally
RUN npm install -g n8n

# Create working directory
WORKDIR /home/node/.n8n

# Copy SSL certificates
COPY certificates /home/node/.n8n/certificates

# Set ownership and switch back to node user
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n
USER node

# Define volumes for persistence
VOLUME ["/home/node/.n8n"]

# Expose HTTPS port
EXPOSE 5678

# Start n8n with HTTPS enabled
CMD ["n8n"]
