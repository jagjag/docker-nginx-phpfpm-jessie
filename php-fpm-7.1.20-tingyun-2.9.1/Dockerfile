
FROM debian:jessie

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php


RUN echo 'deb http://mirrors.163.com/debian/ jessie main non-free contrib ' > /etc/apt/sources.list  \ 
    && echo 'deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib ' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib ' >> /etc/apt/sources.list  \
    && echo 'deb-src http://mirrors.163.com/debian/ jessie main non-free contrib ' >> /etc/apt/sources.list \ 
    && echo 'deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib ' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib ' >> /etc/apt/sources.list \ 
    && echo 'deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib ' >> /etc/apt/sources.list \ 
    && echo 'deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' >> /etc/apt/sources.list 

#RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#    && echo "Asia/Shanghai" > /etc/timezone


# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c \
		# for gd
		libjpeg62-turbo-dev \
		libpng-dev \
		libfreetype6-dev \
        bzip2 \
        # for gd 
        libfreetype6 \
        libfreetype6-dev \
        # for intl extension
        libicu-dev \
        gettext \
        libcurl3 \
        # for mongo
        libcurl4-openssl-dev \
        pkg-config \
        libssl-dev \
        php-mysql \
        cron


# persistent / runtime deps
RUN apt-get update && apt-get install -y \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		xz-utils \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

RUN set -x \
	&& addgroup --gid 800 --system www \
	&& adduser --uid 800 --disabled-password --system --no-create-home --gid 800 www


ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d


ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www --with-fpm-group=www --disable-cgi

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 1729F83938DA44E27BA0F4D3DBDB397470D12172

ENV PHP_VERSION 7.1.20
ENV PHP_URL="https://secure.php.net/get/php-7.1.20.tar.xz/from/this/mirror" PHP_ASC_URL="https://secure.php.net/get/php-7.1.20.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="cd7d1006201459d43fae0790cce4eb3451add5c87f4cadb13b228d4c179b850c" PHP_MD5=""

RUN set -xe; \
	\
	fetchDeps=' \
		wget \
	'; \
	if ! command -v gpg > /dev/null; then \
		fetchDeps="$fetchDeps \
			dirmngr \
			gnupg \
		"; \
	fi; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; ### !!!!! remember to add a "\"  when you open the follow lines
#	\
#	if [ -n "$PHP_ASC_URL" ]; then \
#		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
#		export GNUPGHOME="$(mktemp -d)"; \
#		for key in $GPG_KEYS; do \
#			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
#		done; \
#		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
#		command -v gpgconf > /dev/null && gpgconf --kill all; \
#		rm -rf "$GNUPGHOME"; \
#	fi; \
#	\
#  ## move to the end of enable extension  
#	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps


COPY docker-php-source docker-php-ext-* docker-php-entrypoint /usr/local/bin/

RUN mkdir -p /var/log/php && chown www:www /usr/local/bin/docker-php-* /var/log/php && chmod a+x /usr/local/bin/docker-php-*

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libcurl4-openssl-dev \
		libedit-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		zlib1g-dev \
		${PHP_EXTRA_BUILD_DEPS:-} \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors intead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
	    --enable-embedded-mysqli \  
		--with-gd \
		--with-pdo-mysql \
        --with-iconv \
        --enable-bcmath \
        --enable-shmop \
        --enable-sysvsem \
        --enable-inline-optimization \
        --enable-mbregex \
        --enable-fpm \
        --enable-mbstring \
        --enable-ftp \
        --enable-gd-native-ttf \
        --with-openssl \
        --enable-pcntl \
        --enable-sockets \
        --with-xmlrpc \
        --enable-zip \
        --enable-soap \
        --with-gettext \
        --with-curl \
        --with-jpeg-dir \
        --with-freetype-dir \
        --with-mysqli \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
		--with-libdir="lib/$debMultiarch" \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
	make clean; \
	cd /; \
	docker-php-source delete; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	php --version; \
	\
# https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc



ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]

WORKDIR /neworiental

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf



# enable extension

RUN wget https://github.com/edenhill/librdkafka/archive/v0.11.6.tar.gz -O /tmp/librdkafka-0.11.6.tar.gz \
    && cd /tmp \
    && tar -zxf librdkafka-0.11.6.tar.gz \
    && cd /tmp/librdkafka-0.11.6 \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/librdkafka-0.11.6 /tmp/librdkafka-0.11.6.tar.gz

RUN /usr/local/bin/pecl install mongodb \
    && /usr/local/bin/pecl install redis \
    && /usr/local/bin/pecl install rdkafka 

RUN set -ex \
    && echo 'extension=redis.so' > /usr/local/etc/php/conf.d/redis.ini \
    && echo 'extension=mongodb.so' > /usr/local/etc/php/conf.d/mongodb.ini \
    && echo 'extension=rdkafka.so' > /usr/local/etc/php/conf.d/rdkafka.ini 

COPY www.conf /usr/local/etc/php-fpm.d/
COPY php.ini-production  /usr/local/etc/php/php.ini
COPY php.ini-development /usr/local/etc/php/php.ini-development

RUN mkdir -p /var/log/php && touch /var/log/php/php-fpm_error.log && chown www:www /var/log/php/php-fpm_error.log

RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/local/bin/php  \
    &&  /bin/mv composer.phar /usr/local/bin/composer  \
    &&  composer config -g repo.packagist composer https://packagist.phpcomposer.com 


ENV appname=dockertingyun
COPY tingyun-agent-php-2.9.1.x86_64.deb  /usr/local/tingyun/
RUN dpkg -i /usr/local/tingyun/tingyun-agent-php-2.9.1.x86_64.deb



## purge 
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps

EXPOSE 9000
CMD ["php-fpm"]

