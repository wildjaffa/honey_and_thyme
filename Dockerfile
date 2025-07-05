# Multi-stage build for Flutter web app with nginx
FROM debian:latest AS flutter-builder

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables
ENV FLUTTER_HOME="/opt/flutter"
ENV FLUTTER_VERSION="3.29.2"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
WORKDIR $FLUTTER_HOME
RUN git fetch && git checkout $FLUTTER_VERSION

# Enable web support and get dependencies
RUN flutter config --enable-web
RUN flutter doctor

# Set up the app directory
WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build the web app
RUN flutter build web --release

# Version the assets (add timestamp to main.dart.js)
RUN chmod +x version_assets.sh && ./version_assets.sh

# Nginx stage
FROM nginx:alpine

# Copy the built web app to nginx's html directory
COPY --from=flutter-builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 