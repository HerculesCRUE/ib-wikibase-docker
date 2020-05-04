FROM ubuntu:xenial as fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends unzip=6.* jq=1.* curl=7.* ca-certificates=201* && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY download-extension.sh .

RUN bash download-extension.sh OAuth;\
bash download-extension.sh PluggableAuth;\
bash download-extension.sh OpenIDConnect;\
tar xzf PluggableAuth.tar.gz;\
tar xzf OpenIDConnect.tar.gz;\
rm ./*.tar.gz

FROM wikibase/wikibase:1.34-bundle as base

FROM composer as composer
COPY --from=base /var/www/html /var/www/html
WORKDIR /var/www/html/
# RUN rm /var/www/html/composer.lock
# RUN composer require jumbojett/openid-connect-php --no-update
RUN composer require jumbojett/openid-connect-php
RUN composer install --no-dev

FROM wikibase/wikibase:1.34-bundle
COPY --from=composer /var/www/html /var/www/html
COPY --from=fetcher /PluggableAuth /var/www/html/extensions/PluggableAuth
COPY --from=fetcher /OpenIDConnect /var/www/html/extensions/OpenIDConnect
COPY LocalSettings.php.wikibase-bundle.template /LocalSettings.php.wikibase-bundle.template
# COPY extra-install.sh /
# COPY extra-entrypoint-run-first.sh /
RUN cat /LocalSettings.php.wikibase-bundle.template >> /LocalSettings.php.template && rm /LocalSettings.php.wikibase-bundle.template
# COPY oauth.ini /templates/oauth.ini
