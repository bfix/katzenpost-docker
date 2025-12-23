
#############################################################
# Dockerfile to build  >Y< Katzenpost Client Daemon.
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
    cd cmd/kpclientd && go build -v

FROM debian:trixie AS deploy

COPY --from=builder /go/katzenpost/cmd/kpclientd/kpclientd /usr/bin/kpclientd

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

CMD ["/usr/bin/kpclientd","-c","/conf/client.toml"]
