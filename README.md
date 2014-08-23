MariaDB
=========

Build
-----

```
root@ruo91:~# git clone https://github.com/ruo91/docker-mariadb /opt/docker-mariadb
root@ruo91:~# docker build --rm -t mariadb:10.1 /opt/docker-mariadb
```

Run
---
```
root@ruo91:~# docker run -d --name="mariadb" \
-p 3306:3306 -v /tmp:/tmp mariadb:10.1
```
or
```
root@ruo91:~# docker run -d --name="mariadb" \
-p 3306:3306 -v /tmp:/tmp -v /var/lib/mysql:/var/lib/mysql mariadb:10.1
```
