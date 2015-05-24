#!/bin/bash

########################################################################
# ClassCat/Redmine Asset files
# Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved.
########################################################################

#--- HISTORY -----------------------------------------------------------
# 20-may-15 : 3.0.3
# 18-may-15 : fixed.
#--- TODO --------------------------------------------------------------
# o LANG t.b.supported as an env variable.
#  RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data
#-----------------------------------------------------------------------


######################
### INITIALIZATION ###
######################

function init () {
  echo "ClassCat Info >> initialization code for ClassCat/Redmine"
  echo "Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved."
  echo ""
}


############
### SSHD ###
############

function change_root_password() {
  if [ -z "${ROOT_PASSWORD}" ]; then
    echo "ClassCat Warning >> No ROOT_PASSWORD specified."
  else
    echo -e "root:${ROOT_PASSWORD}" | chpasswd
    # echo -e "${password}\n${password}" | passwd root
  fi
}


function put_public_key() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "ClassCat Warning >> No SSH_PUBLIC_KEY specified."
  else
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
  fi
}


#############
### MYSQL ###
#############

function config_mysql () {
  # echo $MYSQL_ROOT_PASSWORD > /root/mysql_env
  # echo $MYSQL_RM_DBNAME    >> /root/mysql_env
  # echo $MYSQL_RM_USERNAME  >> /root/mysql_env
  # echo $MYSQL_RM_PASSWORD  >> /root/mysql_env

  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql -e "CREATE DATABASE ${MYSQL_RM_DBNAME} CHARACTER SET utf8;"
  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql -e "CREATE USER '${MYSQL_RM_USERNAME}'@'%' IDENTIFIED BY '${MYSQL_RM_PASSWORD}';"
  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_RM_DBNAME}.* TO '${MYSQL_RM_USERNAME}'@'%'"
}


###############
### Redmine ###
###############

function config_redmine () {
  local RM_CONFIG="/usr/local/redmine/config"

  # - Default -
  #  database: redmine
  #  host: localhost
  #  username: root
  #  password: ""

  cp -p "${RM_CONFIG}/database.yml.example" "${RM_CONFIG}/database.yml"

  sed -i.bak2 -e "s/^\s*database\:\s*.*$/  database: ${MYSQL_RM_DBNAME}/"   "${RM_CONFIG}/database.yml"
  sed -i      -e "s/^\s*host\:\s*.*$/  host: mysql/"                        "${RM_CONFIG}/database.yml"
  sed -i      -e "s/^\s*username\:\s*.*$/  username: ${MYSQL_RM_USERNAME}/" "${RM_CONFIG}/database.yml"
  sed -i      -e "s/^\s*password\:\s*.*$/  password: ${MYSQL_RM_PASSWORD}/" "${RM_CONFIG}/database.yml"

  cd /usr/local/redmine
  bundle install --without development test
  bundle exec rake generate_secret_token
  RAILS_ENV=production bundle exec rake db:migrate
  RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data

  mv /var/www/html /var/www/html.orig
  ln -s /usr/local/redmine/public /var/www/html

  chown -R www-data.www-data /usr/local/redmine/log
  chown -R www-data.www-data /usr/local/redmine/tmp
  chown -R www-data.www-data /usr/local/redmine/files
  chown -R www-data.www-data /usr/local/redmine/public/plugin_assets
}


##################
### SUPERVISOR ###
##################
# See http://docs.docker.com/articles/using_supervisord/

function proc_supervisor () {
  cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:ssh]
command=/usr/sbin/sshd -D

[program:apache2]
command=/usr/sbin/apache2ctl -D FOREGROUND

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF
}


### ENTRY POINT ###

init 
change_root_password
put_public_key
config_mysql
config_redmine
proc_supervisor

exit 0


### End of Script ###
