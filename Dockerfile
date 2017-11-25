FROM benyoo/alpine:3.5.20170325
MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ENV VERSION=1.7.9
ENV DOWN_URL=http://www.haproxy.org/download \
	TEMP_DIR=/tmp/haproxy \
	CONF_DIR=/etc/haproxy

RUN set -x && \
	DOWN_URL=${DOWN_URL}/${VERSION%.*}/src/haproxy-${VERSION}.tar.gz && \
	FILE_NAME=${DOWN_URL##*/} && \
	BUILD_DEPS="make gcc g++ linux-headers python pcre-dev openssl-dev zlib-dev tar" && \
	# grab su-exec for easy step-down from root
	RUN_DEPS="pcre libssl1.0 musl libcrypto1.0 busybox zlib supervisor inotify-tools su-exec>=0.2 tar socat" && \
	mkdir -p ${CONF_DIR} ${TEMP_DIR} /data && \
	cd ${TEMP_DIR} && \
	apk --update --no-cache upgrade && \
	apk add --no-cache --virtual build-dependencies ${BUILD_DEPS} && \
	curl -Lk ${DOWN_URL}|tar xz --strip-components=1 -C ${TEMP_DIR} && \
	make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) \
		PREFIX=/usr TARGET=linux2628 USE_PCRE=1 USE_PCRE_JIT=1 USE_OPENSSL=1 USE_ZLIB=1 \
		USE_LUA=$WITH_LUA LUA_LIB=/usr/lib/lua5.3/ LUA_INC=/usr/include/lua5.3 && \
	make PREFIX=/usr install-bin && \
	apk del build-dependencies && \
	apk add --no-cache ${RUN_DEPS} && \
	cd - && \
	rm -rf /tmp/* /var/cache/apk/*
	
ADD etc /etc
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
