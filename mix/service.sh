#!/bin/bash

cd $(dirname "$0")

NAME=katzenpost/mix
CNT=kp-mix
LISTEN=${2:-0.0.0.0:18181}

function run() {
    docker run ${MODE} \
        --name ${CNT} -h ${CNT} \
        -p ${LISTEN}:8181 \
        -v $(pwd)/conf:/conf \
        -v $(pwd)/data:/var/lib/katzenpost \
        -v $(pwd)/logs:/var/log/katzenpost \
        ${NAME} ${EXEC}
}

CMD=${1:-start}
case ${CMD} in
    prep)
        mkdir {conf,data,logs}
        chmod 700 data
        ;;
    build)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/server -g"
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
