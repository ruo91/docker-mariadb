#
# Dockerfile - MariaDB
#
# - Build
# docker build --rm -t mariadb:10.0 .
#
# - Run
# docker run -d --name="mariadb" -h "mariadb" -p 3306:3306 -v /tmp:/tmp mariadb:10.0
#
# - SSH
# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' mariadb`

FROM     ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# Change the repository
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list

# Last Package Update & Install
RUN apt-get update && apt-get install -y supervisor openssh-server nano add-apt-key software-properties-common

# MariaDB 
ENV UBUNTU_VER trusty
ENV MARIADB_VER 10.0
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db \
 && add-apt-repository "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_VER/ubuntu $UBUNTU_VER main" \
 && apt-get update && apt-get install -y mariadb-server mariadb-client

# MariaDB root password
ENV DB_USER root
ENV DB_PASS mariadb
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf \
# && sed -i 's/\/var\/lib\/mysql/\/mariadb/g' /etc/mysql/my.cnf \
 && sed -i 's/\/var\/run\/mysqld\/mysqld.sock/\/tmp\/mysql.sock/g' /etc/mysql/my.cnf \
 && mysql_install_db \
 && echo "#!/bin/bash" > /tmp/mariadb \
 && echo "mysqld_safe &" >> /tmp/mariadb \
 && echo "sleep 5" >> /tmp/mariadb \
 && echo "mysqladmin -u $DB_USER password '$DB_PASS'" >> /tmp/mariadb \
 && echo "mysql -u $DB_USER -p$DB_PASS -e 'GRANT ALL PRIVILEGES ON *.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\";'" >> /tmp/mariadb \
 && echo "mysql -u $DB_USER -p$DB_PASS -e 'FLUSH PRIVILEGES;'" >> /tmp/mariadb \
 && chmod a+x /tmp/mariadb \
 && /tmp/mariadb \
 && rm -f /tmp/mariadb

# my.cnf
RUN echo 'skip-name-resolve' >> /etc/mysql/conf.d/mariadb.cnf

# Supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/without-password/yes/g' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# Root password
RUN echo 'root:mariadb' |chpasswd

# Port
EXPOSE 22 3306

# Daemon
CMD ["/usr/bin/supervisord"]
