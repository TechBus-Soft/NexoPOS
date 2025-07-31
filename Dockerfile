# Start from official PHP image with Apache
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libonig-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-install pdo_mysql mbstring zip bcmath

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer from Composer's official Docker image
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy Laravel project files
COPY . .

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Install Laravel PHP dependencies
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader || true

# Set Apache DocumentRoot to /public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
