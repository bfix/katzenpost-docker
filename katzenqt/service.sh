#!/bin/bash

NAME=katzenpost/qt
CNT=kp-qt
KP_SOCK=/srv/katzenpost/clientd/data/kp.sock

CMD=${1:-start}
case ${CMD} in
    build)
        docker build -t ${NAME} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    start)
        MODE="-d"
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
	--ipc=host \
	-e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
	-e DISPLAY=${DISPLAY} \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /run/user/$(id -u)/pulse:/run/user/1000/pulse \
    -v $(pwd)/conf:/home/user/katzenqt/config \
    -v $(pwd)/data:/home/user/.local/share/katzenqt \
    -v ${KP_SOCK}:/home/user/katzenqt/kp.sock \
    ${NAME} ${EXEC}

${LOG}

