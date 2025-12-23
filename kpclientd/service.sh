#!/bin/bash

NAME=katzenpost/clientd

CMD=${1:-start}
case ${CMD} in
    build)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        LOG="docker logs -f ${NAME}"
        ;;
    stop)
        docker stop ${NAME}
        docker rm ${NAME}
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
    --name kp-clientd -h kp-clientd \
    -v $(pwd)/conf:/conf \
    -v $(pwd)/data:/var/lib/katzenpost \
    ${NAME} ${EXEC}

${LOG}
