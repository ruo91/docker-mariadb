MariaDB
=========
#### - Run
```
root@ruo91:~# docker build --rm -t mariadb:10.0 -p 3306:3306 -v /tmp:/tmp ruo91/mariadb:10.0
```
#### or

#### - Build
```
root@ruo91:~# git clone https://github.com/ruo91/docker-mariadb /opt/docker-mariadb
root@ruo91:~# docker build --rm -t mariadb:10.0 /opt/docker-mariadb
```

#### - Run
```
root@ruo91:~# docker run -d --name="mariadb" -p 3306:3306 -v /tmp:/tmp mariadb:10.1
```

Create user and db
==================
#### - HostOS
user/pass: root, mariadb
```
root@ruo91:~# apt-get install -y mysql-client
root@ruo91:~# mysql -u root -pmariadb \
-e "CREATE DATABASE ruo91;" \
-e "GRANT ALL ON ruo91.* TO 'ruo91'@'%' IDENTIFIED BY '123456789' WITH GRANT OPTION;" \
-e "FLUSH PRIVILEGES;"
```