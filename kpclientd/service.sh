#!/bin/bash

cd $(dirname "$0")

NAME=katzenpost/clientd
CNT=kp-clientd

CMD=${1:-start}
case ${CMD} in
    build)
        ./$0 prep
        ./$0 image
        ./$0 config
        exit
        ;;
    prep)
        mkdir {conf,data}
        chmod 700 data
        exit
        ;;
    image)
        [ -n "$2" ] && VERSION="--build-arg VERSION=$2"
        docker build -t ${NAME} ${VERSION} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    config)
        wget https://raw.githubusercontent.com/katzenpost/katzenqt/refs/heads/main/config/client2.toml -O - \
            | sed -e 's%ListenAddress = "@katzenpost"%ListenAddress = "/var/lib/katzenpost/kp.sock"%' \
            > conf/client.toml
        exit
        ;;
    start)
        MODE="-d --restart=unless-stopped"
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
    clean)
        ./$0 stop
        docker rmi ${CNT}
        rm -rf {conf,data}
        exit
        ;;
    *)
        echo "unknown command"
        exit 1
        ;;
esac

docker run ${MODE} \
    --name ${CNT} -h ${CNT} \
    -v $(pwd)/conf:/conf \
    -v $(pwd)/data:/var/lib/katzenpost \
    ${NAME} ${EXEC}

${LOG}
