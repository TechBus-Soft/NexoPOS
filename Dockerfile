FROM php:8.1-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    zip \
    unzip \
    git \
    curl \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql zip bcmath

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install Composer from official source
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader || true

# Set permissions
RUN chmod -R 775 storage bootstrap/cache || true

# Update Apache doc root to public/
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Expose web port
EXPOSE 80
