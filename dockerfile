ARG NGINX_VERSION=1.19.7
ARG NGINX_RTMP_VERSION=1.2.1
ARG FFMPEG_VERSION=4.3.2


### TARGET::build-nginx
FROM alpine:3.13.2 AS build-nginx
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# get nginx-rtmp module (this section follows first becouse it works not stable, there is DNS problem)
RUN \
  cd /tmp && \
  cat /etc/resolv.conf && \
  wget -O v${NGINX_RTMP_VERSION}.tar.gz https://codeload.github.com/arut/nginx-rtmp-module/tar.gz/v${NGINX_RTMP_VERSION} && \
  ls -la && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# install dependencies
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

# get nginx source
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# compile nginx with nginx-rtmp module
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --prefix=/usr/local/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-debug \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  cd /tmp/nginx-${NGINX_VERSION} && \
  make && \
  make install


### TARGET::build-ffmpeg
FROM alpine:3.13.2 AS build-ffmpeg
ARG FFMPEG_VERSION

RUN apk add --update \
  build-base \
  coreutils \
  freetype-dev \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  openssl-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  wget \
  x264-dev \
  x265-dev \
  yasm

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# get ffmpeg source
RUN cd /tmp/ && \
  wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz

# compile ffmpegs
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --prefix=/usr/local \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --extra-libs="-lpthread -lm" && \
  make && make install && make distclean

# cleanup
RUN rm -rf /var/cache/* /tmp/*


### TARGET::runtime
FROM alpine:3.13.2 AS runtime
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

RUN apk add --update \
  ca-certificates \
  gettext \
  openssl \
  pcre \
  lame \
  libogg \
  curl \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev \
  ffmpeg \
  make \
  bash \
  python3 \
  py3-pip \
  g++ \
  build-base \
  pixman-dev \
  cairo-dev \
  pango-dev \
  jpeg-dev \
  musl-dev \
  giflib-dev \
  pangomm-dev \
  libjpeg-turbo-dev \
  freetype-dev \
  nodejs \
  npm \
  ttf-ubuntu-font-family \
  cmake

# build-base pixman-dev cairo-dev pango-dev jpeg-dev musl-dev giflib-dev pangomm-dev libjpeg-turbo-dev freetype-dev

COPY --from=build-nginx /usr/local/nginx /usr/local/nginx
COPY --from=build-nginx /etc/nginx /etc/nginx
COPY --from=build-ffmpeg /usr/local /usr/local
COPY --from=build-ffmpeg /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2

ENV PATH "${PATH}:/usr/local/nginx/sbin"

RUN \
  mkdir -p /var/log/nginx && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log

RUN \
  echo ">>> /usr/local/nginx/sbin" && \
  ls -la /usr/local/nginx/sbin

CMD ["nginx", "-g", "daemon off;"]
