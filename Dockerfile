FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Ubuntu-Supervisord 3 Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
# 19-may-15 : trusty.
# 17-may-15 : sed -i.bak
# 16-may-15 : php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5.
# 08-may-15 : Created.
#-----------------------------------------------------------------------

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base

RUN update-locale LANG="en_US.UTF-8"

RUN apt-get install -y openssh-server supervisor rsyslog mysql-client \
  apache2 php5 php5-mysql php5-mcrypt php5-intl \
  php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5 \
  && apt-get clean

RUN mkdir -p /var/run/sshd

RUN sed -i.bak -e "s/^PermitRootLogin\s*.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
# RUN sed -i -e 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

RUN php5enmod mcrypt

RUN sed -i.bak -e "s/^;date\.timezone =.*$/date\.timezone = 'Asia\/Tokyo'/" /etc/php5/apache2/php.ini

EXPOSE 22 80

CMD echo "root:${ROOT_PASSWORD}" | chpasswd; /usr/sbin/sshd -D
