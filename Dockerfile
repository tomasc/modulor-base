FROM ruby:2.6.3-alpine

ARG BUNDLER_VERSION=2.1.4
ENV BUNDLER_VERSION ${BUNDLER_VERSION}

RUN apk add --update --no-cache \
      --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
      binutils-gold \
      build-base \
      curl \
      file \
      fontforge-dev \
      g++ \
      gcc \
      git \
      harfbuzz \
      less \
      libc-dev \
      libffi-dev \
      libgcrypt-dev \
      libstdc++ \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      make \
      netcat-openbsd \
      nodejs \
      openssh-client \
      openssl \
      pkgconfig \
      postgresql-dev \
      python \
      tzdata \
      vips-dev \
      woff2-dev \
      yarn

ARG TTF2EOT_VERSION=0.0.2-2
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${TTF2EOT_VERSION}.tar.gz && tar -zxf ttf2eot-${TTF2EOT_VERSION}.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${TTF2EOT_VERSION}/OpenTypeUtilities.h
RUN cd ttf2eot-${TTF2EOT_VERSION} && make && cp ttf2eot /usr/local/bin/ttf2eot && rm -rf ttf2eot*

RUN gem install bundler -v ${BUNDLER_VERSION}
