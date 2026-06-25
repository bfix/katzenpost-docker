#!/bin/bash

cd $(dirname "$0")

NAME=katzenpost/clientd
CNT=kp-clientd

function run() {
    docker run ${MODE} \
        --name ${CNT} -h ${CNT} \
        -v $(pwd)/conf:/conf \
        -v $(pwd)/data:/var/lib/katzenpost \
        -v $(pwd)/log:/var/log/katzenpost \
        ${NAME} ${EXEC}
}

CMD=${1:-start}
VERSION=${2:-main}
case ${CMD} in
    build)
        ./$0 prep
        ./$0 image
        ./$0 config
        ;;
    prep)
        mkdir -p {conf,data,log}
        chmod 700 data
        ;;
    image)
        docker build -t ${NAME} --build-arg VERSION=${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        ;;
    config)
        wget https://raw.githubusercontent.com/katzenpost/katzenqt/refs/heads/main/config/client.toml -O - \
            | sed -e 's%Address = "@katzenpost"%Address = "/var/lib/katzenpost/kp.sock"%' \
            > conf/client.toml
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
    clean)
        ./$0 stop
        docker rmi ${CNT}
        rm -rf {conf,data,logs}
        ;;
    *)
        echo "unknown command"
        exit 1
        ;;
esac
