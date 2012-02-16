# To restore the development database - 
rake data:restore_dev src=tmp/db_110810_1510
mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510
mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510

  
# Resque
PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=file_serve rake environment resque:work
PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=* rake resque:work

 
# Deployment

mongod, redis + resque, rsyslog, nginx + passenger, cron, monit

## commands
sudo /opt/nginx/sbin/nginx -s reload

## Configs
/etc/profile — rubyopt
/etc/apache2/httpd.conf
/apps/bin/ruby — rubyopt
/opt/nginx/conf/nginx.conf
/opt/nginx/conf/sites/
/var/lib/mongodb
/etc/mongodb.conf

## Logs
/var/log/mongodb/mongodb.log
/opt/nginx/logs/error.log

## Reinstalling Passenger and Nginx
  wget http://nginx.org/download/nginx-1.0.12.tar.gz
  tar xzf nginx-1.0.12.tar.gz
  sudo passenger-install-nginx-module
    /home/apprunner/nginx-1.0.12
    --with-http_gzip_static_module

## Installing RVM
sudo bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
sudo usermod -a -G rvm apprunner
