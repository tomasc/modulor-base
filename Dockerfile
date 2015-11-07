FROM ruby:2.2.2
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

# ---------------------------------------------------------------------

# source for MS fonts
RUN echo 'deb http://debian.man.ac.uk/debian/ stable main contrib non-free' | tee -a /etc/apt/sources.list

# UPDATE
RUN apt-get -q update

# BASE
RUN apt-get -y install build-essential git-core libtag1-dev nano

# QT5
RUN apt-get -y install qt5-default libqt5webkit5-dev

# GHOSTSCRIPT
RUN apt-get -y install ghostscript

# IMAGEMAGICK
RUN apt-get -y install imagemagick

# PHANTOMJS
# RUN apt-get -y install build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
# RUN wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
# RUN tar -xvjf phantomjs-1.9.8-linux-x86_64.tar.bz2
# RUN mv phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/local/bin
# RUN chmod +x /usr/local/bin/phantomjs

# PHANTOMJS2
RUN wget --no-check-certificate http://phantomjs-static.s3-website-us-west-2.amazonaws.com/phantomjs
RUN mv phantomjs /usr/local/bin/
RUN chmod +x /usr/local/bin/phantomjs

# FONTS
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
RUN apt-get install -y ttf-mscorefonts-installer

# FONTFORGE
RUN apt-get -y install fontforge
RUN apt-get -y install python-fontforge

# HARFBUZZ
RUN apt-get -y install libglib2.0-dev libcairo2-dev
RUN wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.42.tar.bz2
RUN tar xvf harfbuzz-0.9.42.tar.bz2 --no-same-owner
RUN cd harfbuzz-0.9.42 && ./configure
RUN cd harfbuzz-0.9.42 && make
RUN cd harfbuzz-0.9.42 && make install
RUN rm -rf harfbuzz*

# NODEJS
RUN apt-get -y install nodejs

# NGINX
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN apt-get -q clean

# ---------------------------------------------------------------------

RUN gem install bundler --no-ri --no-rdoc
