FROM sparkpos/docker-nginx-php:7.1-alpine
ENV NEWRELIC_VERSION 8.0.0.204

RUN cd /tmp && \
    curl -O  https://download.newrelic.com/php_agent/release/newrelic-php5-$NEWRELIC_VERSION-linux-musl.tar.gz && \
    tar -zxf  newrelic-php5-$NEWRELIC_VERSION-linux-musl.tar.gz && rm *.tar.gz && \
    cd newrelic-php5-$NEWRELIC_VERSION-linux-musl && \
    NR_INSTALL_SILENT=true ./newrelic-install install

ADD newrelic.sh /app/
ADD supervisord.conf /etc/supervisord.conf
