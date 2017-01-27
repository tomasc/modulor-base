FROM ruby:2.2.5
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

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
RUN apt-get install -y gobject-introspection libgirepository1.0-dev gtk-doc-tools libglib2.0-dev libjpeg62-turbo-dev libpng12-dev libwebp-dev libtiff5-dev libexif-dev libxml2-dev swig libpango1.0-dev libmatio-dev libopenslide-dev libcfitsio3-dev libgif-dev librsvg2-dev libfftw3-dev liblcms2-dev libpangoft2-1.0-0 liborc-0.4-dev libcairo2-dev libfontconfig1 libfontconfig1-dev

# POPPLER
RUN curl -O https://poppler.freedesktop.org/poppler-0.51.0.tar.xz
RUN tar xf poppler-0.51.0.tar.xz && cd poppler-0.51.0 && ./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-build-type=release --enable-cmyk --enable-xpdf-headers --with-testdatadir=$PWD/testfiles && make && make install
RUN rm -rf poppler*

# LIBVIPS
RUN curl -O http://www.vips.ecs.soton.ac.uk/supported/8.4/vips-8.4.5.tar.gz
RUN tar zvxf vips-8.4.5.tar.gz && cd vips-8.4.5 && ./configure && make && make install
RUN rm -rf vips*
RUN export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/
RUN ldconfig

# PDFTK
RUN apt-get -y install pdftk

# PHANTOMJS
RUN wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && tar -xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && chmod +x /usr/local/bin/phantomjs && rm -rf phantomjs*

# FONTFORGE
RUN apt-get -y install fontforge python-fontforge

# HARFBUZZ
RUN wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.3.0.tar.bz2 && tar -xjf harfbuzz-1.3.0.tar.bz2 --no-same-owner
RUN cd harfbuzz-1.3.0 && ./configure && make && make install
RUN rm -rf harfbuzz*

# FONTTOOLS
RUN wget --no-check-certificate https://github.com/behdad/fonttools/archive/3.0.tar.gz && tar -zxf 3.0.tar.gz --no-same-owner
RUN cd fonttools-3.0 && make && make install && rm -rf fonttools*
RUN rm -rf 3.0.tar.gz

# OT-SANITIZER
RUN wget --no-check-certificate https://github.com/khaledhosny/ots/releases/download/v5.0.1/ots-5.0.1.tar.gz && tar -zxf ots-5.0.1.tar.gz
RUN cd ots-5.0.1 && ./configure && make && make install
RUN rm -rf ots-*

# TTF2EOT
RUN wget --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-0.0.2-2.tar.gz && tar -zxf ttf2eot-0.0.2-2.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-0.0.2-2/OpenTypeUtilities.h
RUN cd ttf2eot-0.0.2-2 && make && cp ttf2eot /usr/local/bin/ttf2eot
RUN rm -rf ttf2eot*

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
RUN apt-get -q autoclean
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ---------------------------------------------------------------------

RUN gem install bundler --no-ri --no-rdoc
