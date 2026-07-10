FROM golang:trixie AS builder

LABEL author="<ops@cryptonymity.net>"

ARG VERSION=v0.0.71

RUN \
    cd /go && \
    git clone https://github.com/katzenpost/katzenpost  && \
    cd katzenpost && \
    git checkout ${VERSION} && \
    git rev-parse HEAD > build-commit && \
    go mod tidy && \
    cd cmd/server && go build && \
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

COPY --from=builder /go/katzenpost/cmd/server/server /usr/bin/server
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

CMD ["/usr/bin/server","-f","/conf/gateway.toml"]
