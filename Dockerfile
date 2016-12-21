# Itt választjuk ki, hogy melyik legyen az alap image fájl, amire szeretnénk építeni
FROM nginx:latest

# Ezt szerintem ne változtassuk
MAINTAINER CLAPP hi@clapp.eu

# Innentől kezd érkessé válni, az src mappánkat átmásoljuk az új image docrootjába. Ide fog mutatni a vhost fájlunkban is az útvonal.
#COPY src /usr/share/nginx/html

# átmásoljuk a vhost.conf fájlunk, hogy az NGINX tudja használni.
COPY vhost.conf /etc/nginx/conf.d/default.conf

# Frissítjük az apt-get-et és telepítjuk a PHP5-FPM-et és még egy jópár dolgot. Ide kell felvenni ha esetleg még kell valamilyen PHP extension.
RUN apt-get update && apt-get install -y php5-fpm php5-mcrypt php5-mysql php5-gd php5-curl wget


# Pár konfigutáció, amit elvégzünk. Ezzel érdemes a config fájlokat módosítani, de meg kell majd próbálni ha csak simán felülírjuk őket egy saját fájlal, amiben csak a változtatni kívánt paraméterek vannak, akkor működik-e.

RUN sed -i -e "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@g" /etc/php5/fpm/php.ini && \
	sed -i -e "s@listen = /var/run/php5-fpm.sock@listen = 127.0.0.1:9000@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@upload_max_filesize\s*=\s*2M@upload_max_filesize = 100M@g" /etc/php5/fpm/php.ini && \
	sed -i -e "s@post_max_size\s*=\s*8M@post_max_size = 100M@g" /etc/php5/fpm/php.ini && \
	sed -i -e "s@;daemonize\s*=\s*yes@daemonize = no@g" /etc/php5/fpm/php-fpm.conf && \
	sed -i -e "s@;catch_workers_output\s*=\s*yes@catch_workers_output = yes@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@pm.max_children = 5@pm.max_children = 9@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@pm.start_servers = 2@pm.start_servers = 3@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@pm.min_spare_servers = 1@pm.min_spare_servers = 2@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@pm.max_spare_servers = 3@pm.max_spare_servers = 4@g" /etc/php5/fpm/pool.d/www.conf && \
	sed -i -e "s@pm.max_requests = 500@pm.max_requests = 200@g" /etc/php5/fpm/pool.d/www.conf

# Composer letöltése
RUN cd /usr/share/nginx/html && wget https://getcomposer.org/composer.phar

# Ez pedig már a legvége, itt állítjuk be, hogy milyen legyen az a script, ami a docker run parancsnál lefut.

ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# 80-as portot fogjuk használni
EXPOSE 80

#Ezzel fut le a start.sh script. /bin/bash futtatja a /start.sh scriptet.
CMD ["/bin/bash", "/start.sh"]
