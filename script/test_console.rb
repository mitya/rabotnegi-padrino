
__END__
sudo tail /var/log/syslog

sudo ln -sf /opt/ruby/bin/* /usr/bin
find /usr/bin -lname /opt/ruby/bin/\*
sudo sh -c 'mv /usr/bin/ruby /usr/bin/ruby_en && cp /usr/bin/ruby_ru /usr/bin/ruby'

sudo cat > /usr/bin/ruby_ru
  #!/bin/sh
  export RUBYOPT="-Ku"
  exec "/usr/bin/ruby" "$@"

sudo /opt/nginx/sbin/nginx -s stop
sudo ruby-build 1.9.3-p125 /opt/ruby

cd /app/rabotnegi/current
bundle exec rake -T

q cd app
q cd shared
q cd log
q conf nginx
q conf bash
q log app
q log syslog
q log cron.out
q log cron.err
