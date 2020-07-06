FROM alpine:latest
MAINTAINER Mickael Kerjean <mickael@kerjean.me>

RUN cd /tmp && \
    # install dependencies
    apk add --no-cache apache2 apache2-ctl php7 php7-session php7-apache2 php7-ctype php7-curl php7-json php7-pdo php7-sqlite3 php7-pdo_sqlite php7-mbstring php7-mcrypt php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter && \
    apk add --no-cache curl && \
    # install agendav
    curl -L https://github.com/agendav/agendav/releases/download/2.2.0/agendav-2.2.0.tar.gz > agendav.tar.gz && \
    tar -xzf agendav.tar.gz && \
    rm *.tar.gz && \
    mv agendav* agendav && \
    mv agendav /var/www && \
    cd /var/www/agendav && \
    sed -i "s|'dbname'.*|'dbname' => 'agendav',|" web/config/default.settings.php && \
    sed -i "s|'host'.*|'path' => '/var/www/agendav/web/config/db.sql',|" web/config/default.settings.php && \
    sed -i "s|'driver'.*|'driver' => 'pdo_sqlite'|" web/config/default.settings.php && \
    cp web/config/default.settings.php web/config/settings.php && \
    echo "y" | php agendavcli migrations:migrate && \
    # configure apache
    mkdir /run/apache2 || true && \
    chown -R apache:apache /var/www/agendav/ && \
    sed -i 's|/var/www/localhost/htdocs|/var/www/agendav/web/public|g' /etc/apache2/httpd.conf && \
    # finish installation
    mv /var/www/agendav/web/config /tmp/config

ADD custom.less /var/www/agendav/assets/less/custom.less

RUN apk --no-cache add nodejs python git npm && \
    # build customisations
    cd /var/www/agendav/ && \
    npm install -g bower && \
    bower install --allow-root && \
    npm install && \
    echo "@import \"custom.less\";" >> assets/less/agendav.less && \
    npm run build:css

ADD apache.conf /etc/apache2/conf.d/agenda.conf
ADD run.sh /run.sh

EXPOSE 80
WORKDIR "/var/www"
VOLUME ["/var/log/apache", "/var/www/agendav/web/config"]
ENTRYPOINT ["/run.sh"]