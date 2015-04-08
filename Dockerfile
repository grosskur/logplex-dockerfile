FROM ubuntu:14.04
MAINTAINER Alan Grosskurth <code@alan.grosskurth.ca>

RUN \
  locale-gen en_US.UTF-8 && \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive apt-get -q -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git-core \
    libcurl4-openssl-dev \
    libfontconfig1 \
    libfreetype6 \
    liblzma-dev \
    libmemcached-dev \
    libncurses5-dev \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    pkg-config \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
  mkdir -p /tmp/src /app/logs && \
  cd /tmp/src && \
  curl -fsLS -o logplex-83.tar.gz https://github.com/heroku/logplex/archive/v83.tar.gz && \
  curl -fsLS -o otp_src_R16B03.tar.gz http://www.erlang.org/download/otp_src_R16B03.tar.gz && \
  echo 'f4e74502390a578b0133f343d01c250493d89409852606f95632a3414c64c5d0  logplex-83.tar.gz' | sha256sum -c && \
  echo '6133b3410681a5c934e54c76eee1825f96dead8d6a12c31a64f6e160daf0bb06  otp_src_R16B03.tar.gz' | sha256sum -c && \
  tar -C /app --strip-components=1 -xzf logplex-83.tar.gz && \
  tar -xzf otp_src_R16B03.tar.gz && \
  cd /tmp/src/otp_src_R16B03 && \
  ./configure --prefix=/app/.erlenv/releases/r16b03 && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf /tmp/src && \
  chown -R nobody:nogroup /app

WORKDIR /app
ENV HOME=/app ERL_LIBS=/app/deps PATH=/app/.erlenv/releases/r16b03/bin:$PATH

RUN /app/rebar --config public.rebar.config get-deps compile

COPY bin/run /app/bin/run
USER nobody
EXPOSE 5565 8001 8601

ENTRYPOINT ["/app/bin/run"]
