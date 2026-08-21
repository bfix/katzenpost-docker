
#############################################################
# Dockerfile to build  >Y< Katzenpost replica (storage).
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
    git rev-parse HEAD > build-commit && \
    go mod tidy && \
    cd cmd/replica && go build && \
    cd ../genkeypair && go build


FROM debian:trixie AS deploy


COPY --from=builder /go/katzenpost/cmd/replica/replica /usr/bin/replica
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

COPY --from=builder /go/katzenpost/build-commit /home/user/build-commit

USER user
ENV HOME=/home/user

CMD ["/usr/bin/replica","-f","/conf/replica.toml"]
