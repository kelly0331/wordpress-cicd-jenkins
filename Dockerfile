FROM wordpress:6.6-apache

# Copiar temas y plugins personalizados (se añadirán más adelante)
COPY ./wp-content/ /var/www/html/wp-content/

# Habilitar módulo rewrite y ajustar permisos
RUN a2enmod rewrite && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80
