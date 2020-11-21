ARG UPSTREAM=2.2.25
FROM analogic/poste.io:$UPSTREAM

# Overwriting default Roundcube with latest official version
ENV ROUNDCUBE_VERSION=1.4.9

RUN set -ex; \
	curl -o roundcube-${ROUNDCUBE_VERSION}.tar.gz -fSL "https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz"; \
	mv /opt/www/webmail/config/config.inc.php /tmp/roundcube.config.inc.php; \
	mv /opt/www/webmail/plugins/enigma/config.inc.php /tmp/enigma.config.inc.php; \
	rm -R /opt/www/webmail; \
	tar -xzf roundcube-${ROUNDCUBE_VERSION}.tar.gz -C /opt/www/; \
	mv /opt/www/roundcubemail-${ROUNDCUBE_VERSION} /opt/www/webmail; \
	rm -R /opt/www/webmail/installer; \
	rm /opt/www/webmail/config/config.inc.php*; \
	mv /tmp/roundcube.config.inc.php /opt/www/webmail/config/config.inc.php; \
	mv /tmp/enigma.config.inc.php /opt/www/webmail/plugins/enigma/config.inc.php; \
	rm roundcube-${ROUNDCUBE_VERSION}.tar.gz; \
	mkdir /data/roundcube-plugins

COPY 25-roundcube-plugins.sh /etc/cont-init.d

RUN sed -i '60d;77d' /opt/www/webmail/config/config.inc.php; \
    sed -i '$aforeach ( explode("\\n", file_get_contents("/data/roundcube/installed-plugins")) as $line ) {' /opt/www/webmail/config/config.inc.php; \
    sed -i '$a\    $line = trim($line);' /opt/www/webmail/config/config.inc.php; \
    sed -i '$a\    if ( "" === $line || substr($line,0,1) === "#" || ! is_dir("plugins/$line")) continue;' /opt/www/webmail/config/config.inc.php; \
    sed -i '$a\    $config["plugins"][] = $line;' /opt/www/webmail/config/config.inc.php; \
    sed -i '$a}' /opt/www/webmail/config/config.inc.php; \
