#!/bin/bash

# Process templates with environment variables
envsubst < /app/nginx.conf.template > /etc/nginx/sites-available/default
envsubst < /app/supervisord.conf.template > /etc/supervisor/conf.d/supervisord.conf

# Create data directories if they don't exist
mkdir -p /app/data
mkdir -p /app/data/temp

echo "Starting Telegram Bot API server with the following configuration:"
echo "Bot API port: $BOT_API_PORT"
echo "Web port: $WEB_PORT"
echo "API_ID: $API_ID"
echo "Health check available on port 10000"
echo "Using persistent storage at: /app/data"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
