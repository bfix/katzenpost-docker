#!/bin/bash

docker=${docker:-docker}
export PODMAN_USERNS=keep-id
NAME=kp-replica
IMG=katzenpost/replica
LISTEN=0.0.0.0:28184

#-----------------------------------------------------------------------

function run() {
    chmod 700 data || return
    $docker run ${MODE} \
        --name ${NAME} -h ${NAME} \
        -p ${LISTEN}:8181 \
        -v $(pwd)/conf:/conf \
        -v $(pwd)/data:/var/lib/katzenpost \
        -v $(pwd)/logs:/var/log/katzenpost \
        ${IMG} ${EXEC}
}

cd $(dirname "$0")
[ ! -f conf/listen ] || LISTEN=${2:-$(cat conf/listen)}

CMD=${1:-start}
case ${CMD} in
    prep)
        mkdir -p {conf,data,logs}
        chmod 700 data
        ;;
    build)
        VER=""
        if [ -n "$2" ]; then
            VER="--build-arg VERSION=$2"
        fi
        $docker build -t ${IMG} --no-cache ${VER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/server -f /conf/server.toml -g"
        run
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        EXEC=""
        run
        ;&
    logs)
        $docker logs -f ${NAME}
        ;;
    stop)
        $docker stop ${NAME}
        $docker rm ${NAME}
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
