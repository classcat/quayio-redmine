FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Redmine Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
# 24-may-15 : quay.io
# 20-may-15 : ruby2.1-dev removed.
# 20-may-15 : trusty
# 20-may-15 : 3.0.3
# 18-may-15 : fixed.
#-----------------------------------------------------------------------
# 19-may-15 : trusty.
# 17-may-15 : sed -i.bak
# 16-may-15 : php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5.
# 08-may-15 : Created.
#-----------------------------------------------------------------------

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base \
  && update-locale LANG="en_US.UTF-8" \
  && apt-get install -y openssh-server supervisor rsyslog mysql-client \
    apache2 php5 php5-mysql php5-mcrypt php5-intl \
    php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5 \
  && mkdir -p /var/run/sshd \
  && sed -i.bak -e "s/^PermitRootLogin\s*.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
# RUN sed -i -e 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

RUN php5enmod mcrypt \
  && sed -i.bak -e "s/^;date\.timezone =.*$/date\.timezone = 'Asia\/Tokyo'/" /etc/php5/apache2/php.ini

WORKDIR /usr/local
RUN apt-get install -y libapache2-mod-passenger \
       ruby1.9.1-dev build-essential zlib1g-dev \
       imagemagick libmagickwand-dev libmysqlclient-dev \
  && apt-get clean \
  && gem install bundler \
  && wget http://www.redmine.org/releases/redmine-3.0.3.tar.gz \
  && tar xfz redmine-3.0.3.tar.gz \
  && chown -R root.root /usr/local/redmine-3.0.3 \
  && ln -s /usr/local/redmine-3.0.3 /usr/local/redmine

COPY assets/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY assets/passenger.conf   /etc/apache2/mods-available/passenger.conf

WORKDIR /opt
COPY assets/cc-init.sh /opt/cc-init.sh

EXPOSE 22 80

CMD /opt/cc-init.sh; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
