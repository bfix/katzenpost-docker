#!/bin/bash

NAME=kp-courier
IMG=katzenpost/courier
LISTEN=0.0.0.0:28183

#-----------------------------------------------------------------------

function run() {
    docker run ${MODE} \
        --name ${NAME} -h ${NAME} \
        -p ${LISTEN}:8181 \
        -v $(pwd)/conf:/conf \
        -v $(pwd)/data:/var/lib/katzenpost \
        -v $(pwd)/logs:/var/log/katzenpost \
        ${IMG} ${EXEC}
}

cd $(dirname "$0")

CMD=${1:-start}
case ${CMD} in
    prep)
        mkdir -p {conf,data/courier,logs}
        chmod 700 data
        ;;
    build)
        VER=""
        if [ -n "$2" ]; then
            VER="--build-arg VERSION=$2"
        fi
        docker build -t ${IMG} --no-cache ${VER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    genkeys-link)
        MODE="-ti --rm"
        EXEC="/usr/bin/genkeypair --type kem --scheme KYBER768-X25519 -o /var/lib/katzenpost/courier/courier"
        run
        ;;
    start)
        MODE="-d --restart=unless-stopped"
        EXEC=""
        run
        ;&
    logs)
        docker logs -f ${NAME}
        ;;
    stop)
        docker stop ${NAME}
        docker rm ${NAME}
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

