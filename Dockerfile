FROM ruby:3.2.2
MAINTAINER Tomas Celizna <mail@tomascelizna.com>
ENV LANG C.UTF-8

ARG BUNDLER_VERSION=2.4.10
ARG RUBYGEMS_VERSION=3.4.10
ARG HARFBUZZ_VERSION=7.1.0
ARG TTF2EOT_VERSION=0.0.2-2

RUN apt-get -y update

RUN apt-get -y install \
    apt-transport-https \
    build-essential \
    cmake \
    cron \
    expect-dev \
    git-core \
    libgconf-2-4 \
    libnss3 \
    libtag1-dev \
    lsb-release \
    nano \
    libyaml-dev \
    ruby-psych \
    unzip

RUN apt-get install -y \
    ffmpeg \
    fontforge \
    fontforge \
    gcc \
    g++ \
    gtk-doc-tools \
    libcairo2-dev \
    libexif-dev \
    libfreetype6-dev \
    libfftw3-dev \
    libfontconfig1 \
    libfontconfig1-dev \
    libgif-dev \
    libglib2.0-dev \
    libjpeg62-turbo-dev \
    liblcms2-dev \
    libmatio-dev \
    libopenslide-dev \
    liborc-0.4-dev \
    libpango1.0-dev \
    libpangoft2-1.0-0 \
    libpng-dev \
    librsvg2-dev \
    libtiff5-dev \
    libvips-dev \
    libwebp-dev \
    libxml2-dev \
    libxss1 \
    meson \
    mupdf \
    pdftk \
    pkg-config \
    python-dev \
    python-setuptools \
    python3-fontforge \
    ragel \
    ttfautohint \
    woff2

# NODE
RUN apt-get -y install \
    nodejs

# YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get -q update && apt-get install -y yarn

# HARFBUZZ
RUN wget --no-check-certificate https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VERSION}/harfbuzz-${HARFBUZZ_VERSION}.tar.xz && tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.xz && rm -rf /harfbuzz-${HARFBUZZ_VERSION}.tar.xz
RUN cd harfbuzz-${HARFBUZZ_VERSION} && meson build && meson compile -C build && cd /usr/local/bin && ln -s /harfbuzz-${HARFBUZZ_VERSION}/build/util/hb-view hb-view && cd /

# TTF2EOT
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${TTF2EOT_VERSION}.tar.gz && tar -zxf ttf2eot-${TTF2EOT_VERSION}.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${TTF2EOT_VERSION}/OpenTypeUtilities.h
RUN cd ttf2eot-${TTF2EOT_VERSION} && make && cp ttf2eot /usr/local/bin/ttf2eot && cd / && rm -rf /ttf2eot*

RUN apt-get -q autoclean
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem update --system ${RUBYGEMS_VERSION} && gem update --system
RUN gem install bundler -v ${BUNDLER_VERSION}
