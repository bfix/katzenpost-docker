#!/bin/bash

NAME=katzenpost/gateway
CNT=kp-gateway
LISTEN=${2:-0.0.0.0:28182}

function run() {
    docker run ${MODE} \
        --name ${CNT} -h ${CNT} \
        -p ${LISTEN}:8181 \
        -v $(pwd)/conf:/conf \
        -v ${pwd}/data:/var/lib/katzenpost \
        -v ${pwd}/logs:/var/log/katzenpost \
        ${NAME} ${EXEC}
}

CMD=${1:-start}
case ${CMD} in
    prep)
        mkdir -p {conf,data,logs}
        chmod 700 data
        ;;
    build)
        VER=""
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} --no-cache ${VER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/server -f /conf/gateway.toml -g"
        run
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        EXEC=""
        run
        ;&
    logs)
        docker logs -f ${CNT}
        ;;
    stop)
        docker stop ${CNT}
        docker rm ${CNT}
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

