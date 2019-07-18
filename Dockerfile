FROM tomasce/ruby:2.6.3
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>
ENV LANG C.UTF-8

# UPDATE
RUN apt-get -q update

# BASE
RUN apt-get -y install build-essential cmake git-core libtag1-dev nano cron xvfb expect-dev unzip apt-transport-https lsb-release libx11-dev libnss3 libgconf-2-4

# QT5
RUN apt-get -y install qt5-default libqt5webkit5-dev

# GHOSTSCRIPT
RUN apt-get -y install ghostscript

# GFX LIBS
RUN apt-get install -y gobject-introspection libgirepository1.0-dev gtk-doc-tools libglib2.0-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libtiff5-dev libexif-dev libxml2-dev swig libpango1.0-dev libmatio-dev libopenslide-dev libgif-dev librsvg2-dev libfftw3-dev liblcms2-dev libpangoft2-1.0-0 liborc-0.4-dev libcairo2-dev libfontconfig1 libfontconfig1-dev python-setuptools python-dev

# POPPLER
ENV poppler_version=0.59.0
RUN curl -O https://poppler.freedesktop.org/poppler-${poppler_version}.tar.xz
RUN tar xf poppler-${poppler_version}.tar.xz && cd poppler-${poppler_version} && ./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-build-type=release --enable-cmyk --enable-xpdf-headers --with-testdatadir=$PWD/testfiles && make && make install
RUN rm -rf poppler*

# LIBVIPS
ENV libvips_version=8.7.2
RUN curl -OL https://github.com/libvips/libvips/releases/download/v${libvips_version}/vips-${libvips_version}.tar.gz
RUN tar xvf vips-${libvips_version}.tar.gz && cd vips-${libvips_version} && ./configure $1 && make && make install
RUN rm -rf vips*
RUN export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/
RUN ldconfig

# PDFTK
RUN apt-get -y install pdftk

# FONTFORGE
RUN apt-get -y install fontforge python-fontforge

# HARFBUZZ
ENV harfbuzz_version=2.3.0
RUN wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-${harfbuzz_version}.tar.bz2 && tar -xjf harfbuzz-${harfbuzz_version}.tar.bz2 --no-same-owner
RUN cd harfbuzz-${harfbuzz_version} && ./configure && make && make install && rm -rf harfbuzz*

# MuPDF
ENV mupdf_version=1.14.0
RUN wget --no-check-certificate https://mupdf.com/downloads/archive/mupdf-${mupdf_version}-source.tar.gz && tar zvxf mupdf-${mupdf_version}-source.tar.gz
RUN cd mupdf-${mupdf_version}-source && make HAVE_X11=no HAVE_GLUT=no prefix=/usr/local install && rm -rf mupdf-*

# FONTTOOLS
ENV fonttools_version=3.34.2
RUN curl -OL https://github.com/fonttools/fonttools/releases/download/${fonttools_version}/fonttools-${fonttools_version}.zip && unzip fonttools-${fonttools_version}.zip
RUN easy_install pip
RUN cd fonttools-${fonttools_version} && make && make install && rm -rf fonttools* && rm -rf fonttools-${fonttools_version}.tar.gz

# OT-SANITIZER
ENV ots_version=5.2.0
RUN wget --no-check-certificate https://github.com/khaledhosny/ots/releases/download/v${ots_version}/ots-${ots_version}.tar.gz && tar -zxf ots-${ots_version}.tar.gz
RUN cd ots-${ots_version} && ./configure && make && make install && rm -rf ots-*

# TTF2EOT
ENV ttf2eot_version=0.0.2-2
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${ttf2eot_version}.tar.gz && tar -zxf ttf2eot-${ttf2eot_version}.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${ttf2eot_version}/OpenTypeUtilities.h
RUN cd ttf2eot-${ttf2eot_version} && make && cp ttf2eot /usr/local/bin/ttf2eot && rm -rf ttf2eot*

# TTFAUTOHINT
RUN apt-get -y install ttfautohint

# WOFF2
RUN git clone --recursive https://github.com/google/woff2.git
RUN cd woff2 && make clean all
RUN mv woff2/woff2_* /usr/local/bin && rm -rf woff2

# NODEJS
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get -y install nodejs

# NGINX
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get -q update && apt-get install -y yarn

# GSUTIL & KUBECTL
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && echo "deb https://packages.cloud.google.com/apt ${CLOUD_SDK_REPO} main" > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install google-cloud-sdk -y
RUN apt-get install kubectl

RUN apt-get -q autoclean
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
