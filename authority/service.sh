#!/bin/bash

cd $(dirname "$0")

NAME=katzenpost/authority
CNT=kp-dirauth
LISTEN=${2:-0.0.0.0:28181}

CMD=${1:-start}
case ${CMD} in
    build)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/dirauth -f /conf/authority.toml -g"
        LOG=""
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        EXEC=""
        LOG="docker logs -f ${CNT}"
        ;;
    stop)
        docker stop ${CNT}
        docker rm ${CNT}
        exit
        ;;
    test)
        MODE="-ti --rm"
        EXEC="bash"
        LOG=""
        ;;
    *)
        echo "unknown command"
        exit 1
        ;;
esac

docker run ${MODE} \
    --name ${CNT} -h ${CNT} \
    -p ${LISTEN}:8181 \
    -v $(pwd)/conf:/conf \
    -v $(pwd)/data:/var/lib/katzenpost \
    ${NAME} ${EXEC}

${LOG}
