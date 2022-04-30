FROM ruby:3.1.2
MAINTAINER Tomas Celizna <mail@tomascelizna.com>
ENV LANG C.UTF-8

ARG BUNDLER_VERSION=2.3.12
ARG RUBYGEMS_VERSION=3.3.12
ARG HARFBUZZ_VERSION=2.7.2
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
    unzip

RUN apt-get install -y \
    ffmpeg \
    fontforge \
    gobject-introspection \
    gtk-doc-tools \
    libcairo2-dev \
    libexif-dev \
    libfftw3-dev \
    libfontconfig1 \
    libfontconfig1-dev \
    libgif-dev \
    libgirepository1.0-dev \
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
    mupdf \
    pdftk \
    python-dev \
    python3-fontforge \
    python-setuptools \
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
RUN wget --no-check-certificate https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VERSION}/harfbuzz-${HARFBUZZ_VERSION}.tar.xz && tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.xz
RUN cd harfbuzz-${HARFBUZZ_VERSION} && ./configure && make && make install && rm -rf harfbuzz*

# TTF2EOT
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${TTF2EOT_VERSION}.tar.gz && tar -zxf ttf2eot-${TTF2EOT_VERSION}.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${TTF2EOT_VERSION}/OpenTypeUtilities.h
RUN cd ttf2eot-${TTF2EOT_VERSION} && make && cp ttf2eot /usr/local/bin/ttf2eot && rm -rf ttf2eot*

RUN apt-get -q autoclean
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler -v ${BUNDLER_VERSION}
RUN gem update --system ${RUBYGEMS_VERSION} && gem update --system
