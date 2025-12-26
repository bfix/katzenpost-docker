#!/bin/bash

cd $(dirname "$0")

NAME=katzenpost/qt
CNT=kp-qt
KP_SOCK=$(realpath ../kpclientd/data/kp.sock)

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
        docker build -t ${NAME} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .
        exit
        ;;
    config)
        wget https://raw.githubusercontent.com/katzenpost/katzenqt/refs/heads/main/config/alembic.ini -O conf/alembic.ini
        wget https://raw.githubusercontent.com/katzenpost/katzenqt/refs/heads/main/config/thinclient.toml -O - \
            | sed -e 's%Address = "@katzenpost"%Address = "/home/user/katzenqt/kp.sock"%' \
            > conf/thinclient.toml.toml
        exit
        ;;
    run)
        MODE="-ti --rm"
        EXEC="$2"
        ;;
    clean)
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
	--device /dev/dri \
	-e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
	-e DISPLAY=${DISPLAY} \
   	-e QT_QPA_PLATFORM=xcb \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /run/user/$(id -u)/pulse:/run/user/1000/pulse \
    -v $(pwd)/conf:/home/user/katzenqt/config \
    -v $(pwd)/data:/home/user/.local/share/katzenqt \
    -v ${KP_SOCK}:/home/user/katzenqt/kp.sock \
    ${NAME} ${EXEC}
