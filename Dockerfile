FROM ruby:4.0.6
ENV LANG=C.UTF-8

# `nano` is the only editor in the image — without this, git/`rails
# credentials:edit`/`bundle open` fall back to a `vi` that isn't installed.
ENV EDITOR=nano
ENV VISUAL=nano

ARG BUNDLER_VERSION=4.0.20
ARG RUBYGEMS_VERSION=4.0.20
ARG HARFBUZZ_VERSION=14.4.0
ARG TTF2EOT_VERSION=0.0.2-2
ARG NODE_MAJOR=26

# Don't unpack docs, manpages or message catalogues (what debian:*-slim does).
# Must precede the first install to have any effect. ~150MB.
RUN printf '%s\n' \
  'path-exclude /usr/share/doc/*' \
  'path-include /usr/share/doc/*/copyright' \
  'path-exclude /usr/share/man/*' \
  'path-exclude /usr/share/locale/*' \
  'path-exclude /usr/share/info/*' \
  'path-exclude /usr/share/groff/*' \
  > /etc/dpkg/dpkg.cfg.d/01-nodoc

# One layer, and the apt lists are dropped inside it — a `rm -rf
# /var/lib/apt/lists` in a later layer still ships the bytes in this one.
#
# `--no-install-recommends` is worth ~330MB (mesa-vulkan-drivers, pocketsphinx,
# gfortran, qt translations, …); libvips-tools (the `vips` CLI) and poppler-data
# (CJK PDFs) are recommends we do want, so they are named explicitly.
RUN apt-get -y update && apt-get -y install --no-install-recommends \
  build-essential \
  cmake \
  cron \
  expect-dev \
  git-core \
  libnss3 \
  libtag1-dev \
  lsb-release \
  nano \
  libyaml-dev \
  unzip \
  zip \
  \
  ffmpeg \
  fontforge \
  gcc \
  g++ \
  libcairo2-dev \
  libexif-dev \
  libfreetype6-dev \
  libfftw3-dev \
  libfontconfig1 \
  libfontconfig1-dev \
  libgif-dev \
  libglib2.0-dev \
  libjemalloc2 \
  libjpeg62-turbo-dev \
  liblcms2-dev \
  liborc-0.4-dev \
  libpango1.0-dev \
  libpangoft2-1.0-0 \
  libpng-dev \
  librsvg2-dev \
  libtiff-dev \
  libvips-dev \
  libvips-tools \
  libwebp-dev \
  libxml2-dev \
  libxss1 \
  meson \
  pkg-config \
  poppler-data \
  poppler-utils \
  python-dev-is-python3 \
  python3-brotli \
  python3-fontforge \
  python3-fonttools \
  ragel \
  ttfautohint \
  woff2 \
  && rm -rf /var/lib/apt/lists/*

# NODE + YARN
RUN apt-get -y update && apt-get -y install --no-install-recommends ca-certificates curl gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && apt-get -y update && apt-get -y install nodejs yarn \
  && rm -rf /var/lib/apt/lists/*

# HARFBUZZ
#
# A release build, statically linked, installed — so the source tree goes away
# in the same layer. meson's default buildtype is `debug`: the tree this
# replaces was 806MB of it, and could not be deleted because `hb-view` was a
# symlink into it.
RUN wget -q https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VERSION}/harfbuzz-${HARFBUZZ_VERSION}.tar.xz \
  && tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.xz \
  && cd harfbuzz-${HARFBUZZ_VERSION} \
  && meson setup build --buildtype=release --default-library=static --prefix=/usr/local \
       -Dtests=disabled -Ddocs=disabled -Dutilities=enabled \
  && meson compile -C build \
  && meson install -C build --tags runtime,bin \
  && strip /usr/local/bin/hb-* \
  && cd / && rm -rf /harfbuzz-${HARFBUZZ_VERSION} /harfbuzz-${HARFBUZZ_VERSION}.tar.xz

# TTF2EOT
RUN wget -q --no-check-certificate https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ttf2eot/ttf2eot-${TTF2EOT_VERSION}.tar.gz \
  && tar -zxf ttf2eot-${TTF2EOT_VERSION}.tar.gz \
  && sed -i.bak "/using std::vector;/ i\#include <cstddef>" /ttf2eot-${TTF2EOT_VERSION}/OpenTypeUtilities.h \
  && cd ttf2eot-${TTF2EOT_VERSION} && make && cp ttf2eot /usr/local/bin/ttf2eot \
  && cd / && rm -rf /ttf2eot*

RUN gem update --system ${RUBYGEMS_VERSION} && gem install bundler -v ${BUNDLER_VERSION}
