
# Base PHP image with Apache
FROM php:8.1-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install required PHP extensions and dependencies (including oniguruma)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \                    # ✅ Fixes mbstring error (oniguruma)
    zip \
    unzip \
    git \
    curl \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo pdo_mysql gd mbstring zip bcmath

# Set working directory
WORKDIR /var/www/html

# Copy all project files
COPY . .

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Run Composer install with optimized autoloading
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev --optimize-autoloader

# Laravel: Create necessary directories and set correct permissions
RUN mkdir -p storage/framework/{cache,sessions,views} && \
    chmod -R 775 storage bootstrap/cache

# Laravel: Run config and view optimizations
RUN php artisan config:clear && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Laravel (optional): Run database migrations in production (uncomment if DB is ready)
# RUN php artisan migrate --force

# Apache: Set DocumentRoot to Laravel public/ folder
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
 && echo '<Directory "/var/www/html/public">
    AllowOverride All
    Require all granted
</Directory>' >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80
