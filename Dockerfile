FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone and build the telegram-bot-api
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git &&    cd telegram-bot-api &&    rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
# Set default port values
ENV BOT_API_PORT=8081
ENV WEB_PORT=8080

# Install dependencies
RUN apt-get update &&    apt-get install -y    libssl-dev    nginx    supervisor    gettext-base    curl    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/telegram-bot-api/bin/telegram-bot-api /usr/local/bin/

# Create necessary directories
RUN mkdir -p /app/data /app/data/temp

# Create a simple health check response file
RUN mkdir -p /var/www/health &&    echo '{"status":"ok","message":"Telegram Bot API Health Check"}' > /var/www/health/index.json

# Copy configuration files
COPY nginx.conf.template /app/nginx.conf.template
COPY supervisord.conf.template /app/supervisord.conf.template
COPY start.sh /app/start.sh

# Make scripts executable
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 8080 8081 10000

# Run the start script
CMD ["/app/start.sh"]
