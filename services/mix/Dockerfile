
#############################################################
# Dockerfile to build  >Y< Katzenpost Mixserver.
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
	cd cmd/server && go build

FROM debian:trixie AS deploy

COPY --from=builder /go/katzenpost/cmd/server/server /usr/bin/server

EXPOSE 8181

RUN \
	apt update && \
	apt install -y --no-install-recommends \
		adduser \
		&& \
	apt clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

CMD ["/usr/bin/server","-f","/conf/mix.toml"]

