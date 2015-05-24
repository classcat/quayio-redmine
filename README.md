# Redmine

## Summary

Dockerized Redmine ( [Redmine](http://www.redmine.org/) ).
Run Redmine under the control of supervisor daemon in a docker container.

Ubuntu Vivid/Trusty redmine images with :

+ Redmine 3.0.3
+ supervisord
+ sshd

built on the top of the formal Ubuntu images.

## Maintainer

[ClassCat Co.,Ltd.](http://www.classcat.com/) (This website is written in Japanese.)

## TAGS

+ latest - vivid
+ vivid
+ trusty

## Pull Image

```
$ sudo docker pull classcat/redmine
```

## Requirement

mysql container to link with mysql root password.

## Usage

```
docker run -d --name (container-name) \  
  -p 2022:22 -p 80:80 \  
  --link (mysql-container-name):mysql \  
  -e ROOT_PASSWORD=(root-password) \  
  -e SSH_PUBLIC_KEY="ssh-rsa xxx" \  
  -e MYSQL_ROOT_PASSWORD=(mysql-root-password) \  
  -e MYSQL_RM_DBNAME=(database-name) \  
  -e MYSQL_RM_USERNAME=(database-username) \  
  -e MYSQL_RM_PASSWORD=(database-password) \  
  classcat/redmine
```

## Example usage

```
docker run -d --name redmine -p 2022:22 -p 80:80 \  
  -e ROOT_PASSWORD=mypassword \  
  --link mysql:mysql \  
  -e MYSQL_ROOT_PASSWORD=mysqlpassword \  
  -e MYSQL_RM_DBNAME=redmine \  
  -e MYSQL_RM_USERNAME=redmine \  
  -e MYSQL_RM_PASSWORD=redminepassword \  
  classcat/redmine
```

