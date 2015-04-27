FROM	ubuntu:trusty
MAINTAINER	Fredrik Wollsén "fredrik@neam.se"

# prevent apt from starting db right after the installation
RUN	printf '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d

RUN apt-get update && \
  echo mysql-server-5.6 mysql-server/root_password password 'a_stronk_password' | debconf-set-selections && \
  echo mysql-server-5.6 mysql-server/root_password_again password 'a_stronk_password' | debconf-set-selections && \
  LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.6 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

ADD	. /usr/bin
RUN	chmod +x /usr/bin/start_db.sh

# allow autostart again
RUN	rm /usr/sbin/policy-rc.d

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i -e"s/var\/lib/opt/g" /etc/mysql/my.cnf

# skip reverse DNS lookup of clients (hostnames are not used for authentication and this prevents the db server performance problems if dns is down or slow for some reason)
RUN printf '[mysqld]\nskip-name-resolve\n' > /etc/mysql/conf.d/skip-name-resolve.cnf
