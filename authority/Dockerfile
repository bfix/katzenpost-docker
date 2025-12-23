
#############################################################
# Dockerfile to build  >Y< Katzenpost Directory Authority.
# Copyright (c) 2025-present, Bernd Fix. All rights reserved.
#############################################################

FROM golang:trixie AS builder

LABEL author="<ops@cryptonymity.net>"

ARG VERSION=main

RUN \
    cd /go && \
    git clone https://github.com/katzenpost/katzenpost  && \
    cd katzenpost && \
    git checkout ${VERSION} && \
    go mod tidy && \
    cd cmd/dirauth && go build && \
    cd ../genkeypair && go build

FROM debian:trixie AS deploy

RUN apt update && \
    apt-get install -y --no-install-recommends \
    adduser \
    ca-certificates \
    tzdata && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /go/katzenpost/cmd/dirauth/dirauth /usr/bin/dirauth
COPY --from=builder /go/katzenpost/cmd/genkeypair/genkeypair /usr/bin/genkeypair

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

USER user
ENV HOME=/home/user

CMD ["/usr/bin/dirauth","-f","/conf/authority.toml"]
