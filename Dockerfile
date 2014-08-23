#
# Dockerfile - MariaDB
#
# - Build
# git clone https://github.com/ruo91/docker-mariadb /opt/docker-mariadb
# docker build --rm -t mariadb:10.1 /opt/docker-mariadb
#
# - Run
# docker run -d --name="mariadb" -h "mariadb" -p 3306:3306 -v /tmp:/tmp mariadb:10.1
#
# - SSH
# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' mariadb`

FROM     ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# Last Package Update & Install
RUN apt-get update && apt-get install -y supervisor add-apt-key software-properties-common

# MariaDB 
ENV UBUNTU_VER trusty
ENV MARIADB_VER 10.1
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db \
 && add-apt-repository "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_VER/ubuntu $UBUNTU_VER main" \
 && apt-get update && apt-get install -y mariadb-server

# MariaDB root password
ENV DB_USER root
ENV DB_PASS mariadb
RUN sed -i 's/bind-address/\#bind-address/g' /etc/mysql/my.cnf && sed -i 's/\/var\/run\/mysqld\/mysqld.sock/\/tmp\/mysql.sock/g' /etc/mysql/my.cnf \
 && echo "#!/bin/bash" > /tmp/mariadb && echo "mysqld_safe &" >> /tmp/mariadb && echo "sleep 10" >> /tmp/mariadb \
 && echo "mysqladmin -u $DB_USER password '$DB_PASS'" >> /tmp/mariadb && chmod a+x /tmp/mariadb && /tmp/mariadb && rm -f /tmp/mariadb

# Allow remote connection to MariaDB
RUN echo '#!/bin/bash' > /tmp/allow-remote-connection.sh \
 && echo "mysql -u $DB_USER -p$DB_PASS -e 'GRANT ALL PRIVILEGES ON *.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\";'" >> /tmp/allow-remote-connection.sh \
 && echo "mysql -u $DB_USER -p$DB_PASS -e 'FLUSH PRIVILEGES;'" >> /tmp/allow-remote-connection.sh \
 && chmod a+x /tmp/allow-remote-connection.sh

# Supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Port
EXPOSE 3306

# Daemon
CMD ["/usr/bin/supervisord"]
