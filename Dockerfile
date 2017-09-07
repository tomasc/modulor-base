FROM ruby:2.2.5
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

# ---------------------------------------------------------------------

ENV fonttools_version=3.15.1
ENV harfbuzz_version=1.3.0
ENV libvips_version=8.5.8
ENV ots_version=6.0.0
ENV phantomjs_version=2.1.1
ENV poppler_version=0.59.0
ENV ttf2eot_version=0.0.2-2

# ---------------------------------------------------------------------

# UPDATE
RUN apt-get -q update

# BASE
RUN apt-get -y install build-essential git-core libtag1-dev nano cron xvfb expect-dev

# QT5
RUN apt-get -y install qt5-default libqt5webkit5-dev

# GHOSTSCRIPT
RUN apt-get -y install ghostscript

# GFX LIBS
RUN apt-get install -y gobject-introspection gtk-doc-tools libglib2.0-dev libjpeg62-turbo-dev libpng12-dev libwebp-dev libtiff5-dev libexif-dev libxml2-dev swig libpango1.0-dev libmatio-dev libopenslide-dev libcfitsio3-dev libgif-dev librsvg2-dev libfftw3-dev liblcms2-dev libpangoft2-1.0-0 liborc-0.4-dev libcairo2-dev libfontconfig1 libfontconfig1-dev

# POPPLER
RUN curl -O https://poppler.freedesktop.org/poppler-${poppler_version}.tar.xz
RUN tar xf poppler-${poppler_version}.tar.xz && cd poppler-${poppler_version} && ./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-build-type=release --enable-cmyk --enable-xpdf-headers --with-testdatadir=$PWD/testfiles && make && make install
RUN rm -rf poppler*

# LIBVIPS
RUN curl -OL https://github.com/jcupitt/libvips/releases/download/v${libvips_version}/vips-${libvips_version}.tar.gz
RUN tar zvxf vips-${libvips_version}.tar.gz && cd vips-${libvips_version} && ./configure $1 && make && make install
RUN rm -rf vips*
RUN ldconfig

# PDFTK
RUN apt-get -y install pdftk

# PHANTOMJS
RUN wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${phantomjs_version}-linux-x86_64.tar.bz2 && tar -xjf phantomjs-${phantomjs_version}-linux-x86_64.tar.bz2
RUN mv phantomjs-${phantomjs_version}-linux-x86_64/bin/phantomjs /usr/local/bin && chmod +x /usr/local/bin/phantomjs && rm -rf phantomjs*

# FONTFORGE
RUN apt-get -y install fontforge python-fontforge

# HARFBUZZ
RUN wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-${harfbuzz_version}.tar.bz2 && tar -xjf harfbuzz-${harfbuzz_version}.tar.bz2 --no-same-owner
RUN cd harfbuzz-${harfbuzz_version} && ./configure && make && make install && rm -rf harfbuzz*

# FONTTOOLS
RUN wget --no-check-certificate https://github.com/fonttools/fonttools/releases/download/${fonttools_version}/fonttools-${fonttools_version}.zip && tar -zxf fonttools-${fonttools_version}.zip --no-same-owner
RUN cd fonttools-${fonttools_version} && make && make install && rm -rf fonttools* && rm -rf fonttools-${fonttools_version}.tar.gz

# OT-SANITIZER
RUN wget --no-check-certificate https://github.com/khaledhosny/ots/releases/download/v${ots_version}/ots-${ots_version}.tar.gz && tar -zxf ots-${ots_version}.tar.gz
RUN cd ots-${ots_version} && ./configure && make && make install && rm -rf ots-*

# TTF2EOT
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
RUN apt-get -y install nodejs

# NGINX
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN apt-get -y remove automake build-essential
RUN apt-get -q -y autoremove
RUN apt-get -q autoclean
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ---------------------------------------------------------------------

RUN gem install bundler --no-ri --no-rdoc
