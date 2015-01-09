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
  curl -fsLS -o logplex-78.tar.gz https://github.com/heroku/logplex/archive/v78.tar.gz && \
  curl -fsLS -o otp_src_R16B02.tar.gz http://www.erlang.org/download/otp_src_R16B02.tar.gz && \
  echo '8a7c2fb31ba4535ef5ef38be659446f7a46509d067f63c336596c8b6f93b3cec  logplex-78.tar.gz' | sha256sum -c && \
  echo '6ab8ad1df8185345554a4b80e10fd8be06c4f2b71b69dcfb8528352787b32f85  otp_src_R16B02.tar.gz' | sha256sum -c && \
  tar -C /app --strip-components=1 -xzf logplex-78.tar.gz && \
  tar -xzf otp_src_R16B02.tar.gz && \
  cd /tmp/src/otp_src_R16B02 && \
  ./configure --prefix=/app/.erlenv/releases/r16b02 && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf /tmp/src && \
  chown -R nobody:nogroup /app

WORKDIR /app
ENV HOME=/app ERL_LIBS=/app/deps PATH=/app/.erlenv/releases/r16b02/bin:$PATH

RUN /app/rebar --config public.rebar.config get-deps compile

COPY bin/run /app/bin/run
USER nobody
EXPOSE 5565 8001 8601

ENTRYPOINT ["/app/bin/run"]
