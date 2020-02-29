FROM ruby:2.6.3-alpine

ARG BUNDLER_VERSION=2.1.4
ENV BUNDLER_VERSION ${BUNDLER_VERSION}

RUN apk add --update --no-cache \
      --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    	autoconf \
    	automake \
    	bc \
    	expat-dev \
    	fftw-dev \
    	giflib-dev \
    	glib-dev \
    	jpeg-dev \
    	lcms2-dev \
    	libexif-dev \
    	libgsf-dev \
    	libjpeg-turbo-dev \
    	libpng-dev \
    	libtool \
    	libwebp-dev \
    	orc-dev \
    	tiff-dev \
    	zlib-dev \
      binutils-gold \
      build-base \
      build-base \
      ca-certificates \
      chromium \
      curl \
      file \
      fontforge-python3 \
      g++ \
      gcc \
      gdk-pixbuf-dev \
      git \
      glib-dev\
      harfbuzz \
      less \
      libc-dev \
      libffi-dev \
      libgcrypt-dev \
      librsvg-dev \
      libstdc++ \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      make \
      netcat-openbsd \
      nodejs \
      nss \
      openssh-client \
      openssl \
      pkgconfig \
      poppler-dev \
      postgresql-dev \
      python \
      sqlite-dev \
      tzdata \
      woff2-dev \
      yarn

ARG VIPS_VERSION=8.9.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download
RUN wget -O- ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz | tar xzC /tmp
RUN cd /tmp/vips-${VIPS_VERSION} \
  	&& ./configure --prefix=/usr --disable-static --disable-debug \
  	&& make V=0 \
  	&& make install
RUN rm -rf vips-${VIPS_VERSION}.tar.gz
RUN rm -rf /tmp/vips-${VIPS_VERSION}

ENV CHROME_BIN_PATH /usr/bin/chromium-browser

ARG TTF2EOT_VERSION=0.0.2-2
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${TTF2EOT_VERSION}.tar.gz && tar -zxf ttf2eot-${TTF2EOT_VERSION}.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${TTF2EOT_VERSION}/OpenTypeUtilities.h
RUN cd ttf2eot-${TTF2EOT_VERSION} && make && cp ttf2eot /usr/local/bin/ttf2eot && rm -rf ttf2eot*

RUN gem install bundler -v ${BUNDLER_VERSION}
