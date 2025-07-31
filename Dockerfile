# Use PHP 8.1 with Apache
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libonig-dev libxml2-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring zip bcmath gd

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Composer from Composer's image
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy Laravel/NexoPOS source code
COPY . .

# Set correct Laravel permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader || true

# Set Apache to serve Laravel's public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
