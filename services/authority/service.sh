#!/bin/bash

docker=${docker:-docker}
export PODMAN_USERNS=keep-id
NAME=katzenpost/authority
CNT=kp-dirauth
LISTEN=${2:-0.0.0.0:28181}

#-----------------------------------------------------------------------

function run() {
    chmod 700 data || return
    $docker run ${MODE} \
        --name ${CNT} -h ${CNT} \
        -p ${LISTEN}:8181 \
        -v $(pwd)/conf:/conf \
        -v $(pwd)/data:/var/lib/katzenpost \
        -v $(pwd)/logs:/var/log/katzenpost \
        ${NAME} ${EXEC}
}

cd $(dirname "$0")
[ ! -f conf/listen ] || LISTEN=${2:-$(cat conf/listen)}

CMD=${1:-start}
case ${CMD} in
    prep)
        mkdir {conf,data,logs}
        chmod 700 data
        ;;
    build)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        $docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/dirauth -f /conf/authority.toml -g"
        run
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        EXEC=""
        run
        ;&
    logs)
        LOG="$docker logs -f ${CNT}"
        ;;
    stop)
        $docker stop ${CNT}
        $docker rm ${CNT}
        ;;
    test)
        MODE="-ti --rm"
        EXEC="bash"
        run
        ;;
    *)
        echo "unknown command"
        exit 1
        ;;
esac
