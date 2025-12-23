FROM debian:trixie

LABEL author="<ops@cryptonymity.net>"

ENV DEBIAN_FRONTEND=noninteractive

RUN \
	apt update && \
	apt install -y --no-install-recommends \
		sudo \
		ca-certificates \
		git \
		libxcb-cursor-dev \
		libgl1 \
		libegl1 \
		libpulse0 \
		libfontconfig \
		libxkbcommon-dev \
		libpipewire-0.3-dev \
		libpipewire-0.3-modules-x11 \
		pulseaudio-utils \
		pkg-config \
		pipx \
		python3 \
		python3-venv \
		x11-utils \
		qt6-qpa-plugins \
		qt6-base-examples \
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
		user > /dev/null 2>&1 && \
	echo "user:test" | chpasswd && \
	usermod -aG sudo user && \
	echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
	chmod 0640 /etc/sudoers.d/user

COPY run-client /home/user/run-client

RUN \
	chown -R user:user /home/user

USER user
ENV HOME=/home/user

RUN \
    cd ${HOME} && \
    git clone https://github.com/katzenpost/katzenqt && \
    cd katzenqt && \
	pipx install -f uv && \
	export PATH=${PATH}:${HOME}/.local/bin && \
	uv venv .venv && \
	uv pip install . && \
	uv pip install -U pytest

CMD ["/home/user/run-client"]

