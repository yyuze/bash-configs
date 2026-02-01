#!/bin/bash
PWD=$(pwd)

help() {
    echo "usage: $0 -p PROXY"
    echo
    echo "options:"
    echo "  -p PROXY       http proxy, which can be accessed in the docker"
    echo
    echo "example:"
    echo "  $0 -p http://192.168.xxx.xxx:7890"
}

proxy=""
while getopts ":p:" opt; do
    case $opt in
    p)
        proxy="$OPTARG"
        ;;
    \?)
        echo "unknown option: -$OPTARG" >&2
        help
        exit 1
        ;;
    :)
        help
        exit 1
        ;;
    esac
done

if [ -z "${proxy}" ]; then
    echo "proxy is required"
    help
    exit 1
fi

docker build \
--build-arg PROXY="${proxy}" \
--build-arg HOST_USER="${SUDO_USER}" \
--build-arg HOST_UID="${SUDO_UID}" \
--build-arg HOST_GID="${SUDO_GID}" \
--build-arg USER_HOME="${HOME}" \
-f ${PWD}/Dockerfile \
-t yyuze_env \
.
