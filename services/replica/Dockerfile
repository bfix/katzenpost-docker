
#############################################################
# Dockerfile to build  >Y< Katzenpost replica (storage).
# Copyright (c) 2025-present, Bernd Fix. All rights reserved.
#############################################################

FROM golang:trixie AS builder

LABEL author="<ops@cryptonymity.net>"

ARG VERSION=v0.0.71

RUN \
    apt update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    g++-14 \
    libzstd-dev \
    liblz4-dev \
    zlib1g-dev \
    libsnappy-dev \
    libbz2-dev \
    liburing-dev \
    libgflags-dev \
    git \
    pkg-config \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
    cd /usr/local/src && \
    git clone --depth 1 --branch v10.2.1 https://github.com/facebook/rocksdb.git && \
    cd rocksdb && \
    env CC=gcc-14 CXX=g++-14 make shared_lib -j"$(nproc)" && \
    env CC=gcc-14 CXX=g++-14 make install-shared && \
    ldconfig && find / -name rocksdb.so.10.2

RUN \
    cd /go && \
    git clone https://github.com/katzenpost/katzenpost  && \
    cd katzenpost && \
    git checkout ${VERSION} && \
    git rev-parse HEAD > build-commit && \
    go mod tidy && \
    cd cmd/replica && go build && \
    cd ../genkeypair && go build


FROM debian:trixie AS deploy


COPY --from=builder /go/katzenpost/cmd/replica/replica /usr/bin/replica
COPY --from=builder /usr/local/lib/librocksdb.so.10.2 /usr/lib
COPY --from=builder /usr/local/lib/librocksdb.so.10 /usr/lib
COPY --from=builder /usr/local/lib/librocksdb.so /usr/lib
COPY --from=builder /go/katzenpost/cmd/genkeypair/genkeypair /usr/bin/genkeypair

RUN \
    ldconfig && \
    apt update && \
    apt-get install -y --no-install-recommends \
    libsnappy1v5 \
    libzstd1 \
    liblz4-1 \
    zlib1g \
    libgflags2.2 \
    liburing2 \
    adduser \
    ca-certificates \
    tzdata && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8181

ARG uid=1000
ARG gid=1000

RUN \
	addgroup --gid ${gid} user && \
	adduser \
		--home /home/user \
		--shell /bin/bash \
		--uid ${uid} --gid ${gid} \
		--quiet \
		user > /dev/null 2>&1

COPY --from=builder /go/katzenpost/build-commit /home/user/build-commit

USER user
ENV HOME=/home/user

CMD ["/usr/bin/replica","-f","/conf/replica.toml"]
