FROM public.ecr.aws/x5r7l5k8/php:8.1-fpm as base
RUN apt-get update && apt-get install -y libzip-dev zip libicu-dev g++
RUN docker-php-ext-install pcntl intl zip pdo pdo_mysql
RUN pecl install -f pcov && docker-php-ext-enable pcov
RUN apt-get -y --purge remove g++
COPY --from=public.ecr.aws/composer/composer:2.3.5 /usr/bin/composer /usr/local/bin/composer
RUN mkdir -p /var/www/app
RUN chown www-data:www-data /var/www/app

FROM base as local
WORKDIR /var/www/app
COPY entrypoint.dev.sh /tmp
RUN chmod +x /tmp/entrypoint.dev.sh
USER www-data
CMD ["/tmp/entrypoint.dev.sh"]

# `docker build --target prod --tag the-bin:1.0.0 .`
FROM base as production
WORKDIR /var/www/app
COPY src/ .
RUN chown -R www-data:www-data /var/www/app
USER www-data
RUN composer install \
    -v \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist
RUN rm -f composer.json composer.lock

COPY --chown=root:root entrypoint.prd.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.prd.sh"]

CMD ["php-fpm"]
