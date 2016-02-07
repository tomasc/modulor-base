FROM ruby:2.2.2
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

# ---------------------------------------------------------------------

RUN export TERM=xterm

# ---------------------------------------------------------------------

# UPDATE
RUN apt-get -q update

# BASE
RUN apt-get -y install build-essential git-core libtag1-dev nano cron

# GHOSTSCRIPT
RUN apt-get -y install ghostscript

# IMAGEMAGICK
RUN apt-get -y install imagemagick

# PDFTK
RUN apt-get -y install pdftk

# PHANTOMJS
RUN apt-get -y install libfontconfig1 libfontconfig1-dev
RUN wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && tar zxvf phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && chmod +x /usr/local/bin/phantomjs && rm -rf phantomjs*

# FONTFORGE
RUN apt-get -y install fontforge python-fontforge

# HARFBUZZ
RUN apt-get -y install libglib2.0-dev libcairo2-dev
RUN wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.42.tar.bz2 && tar zxvf harfbuzz-0.9.42.tar.bz2 --no-same-owner
RUN cd harfbuzz-0.9.42 && ./configure && make && make install && rm -rf harfbuzz*

# TTF2EOT
RUN wget --no-check-certificate https://ttf2eot.googlecode.com/files/ttf2eot-0.0.2-2.tar.gz && tar zxvf ttf2eot-0.0.2-2.tar.gz
RUN sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-0.0.2-2/OpenTypeUtilities.h
RUN cd ttf2eot-0.0.2-2 && make && cp ttf2eot /usr/local/bin/ttf2eot && rm -rf ttf2eot*

# NODEJS
RUN apt-get -y install nodejs

# NGINX
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN apt-get -q clean

# ---------------------------------------------------------------------

RUN gem install bundler --no-ri --no-rdoc
