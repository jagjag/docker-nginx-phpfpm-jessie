FROM dir.staff.xdf.cn/xdf-pub/php:7.1.20-fpm-jessie-xdf
MAINTAINER ordinarymen
ENV appname=dockertingyun
COPY tingyun-agent-php-2.9.1.x86_64.deb  /usr/local/tingyun/
RUN dpkg -i /usr/local/tingyun/tingyun-agent-php-2.9.1.x86_64.deb
COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
#ENTRYPOINT  ["/usr/local/tingyun/run.sh"]
