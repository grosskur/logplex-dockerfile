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
  curl -fsLS -o logplex-86.tar.gz https://github.com/heroku/logplex/archive/v86.tar.gz && \
  curl -fsLS -o otp_src_R16B03-1.tar.gz http://www.erlang.org/download/otp_src_R16B03-1.tar.gz && \
  echo '9e04951ee5814e278630f7aaf637608790950af8086768fccaf802edc5c60aaf  logplex-86.tar.gz' | sha256sum -c && \
  echo '17ce53459bc5ceb34fc2da412e15ac8c23835a15fbd84e62c8d1852704747ee7  otp_src_R16B03-1.tar.gz' | sha256sum -c && \
  tar -C /app --strip-components=1 -xzf logplex-86.tar.gz && \
  tar -xzf otp_src_R16B03-1.tar.gz && \
  cd /tmp/src/otp_src_R16B03-1 && \
  ./configure --prefix=/app/.local/otp && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf /tmp/src && \
  chown -R nobody:nogroup /app

WORKDIR /app
ENV HOME=/app ERL_LIBS=/app/deps PATH=/app/.local/otp/bin:$PATH

RUN /app/rebar --config public.rebar.config get-deps compile

COPY bin/run /app/bin/run
USER nobody
EXPOSE 5565 8001 8601

ENTRYPOINT ["/app/bin/run"]
