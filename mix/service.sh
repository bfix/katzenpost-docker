#!/bin/bash

NAME=katzenpost/mix
CNT=kp-mix

CMD=${1:-start}
case ${CMD} in
    build)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    genkeys)
        MODE="-ti --rm"
        EXEC="/usr/bin/server -g"
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
    -p 0.0.0.0:18181:8181 \
    -v $(pwd)/conf:/conf \
    -v $(pwd)/data:/var/lib/katzenpost \
    ${NAME} ${EXEC}

${LOG}
