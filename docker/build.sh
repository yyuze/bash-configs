#!/bin/bash
PWD=$(pwd)

help() {
    echo "usage: $0 -p PROXY [--cuda]"
    echo
    echo "options:"
    echo "  -p PROXY       http proxy, which can be accessed in the docker"
    echo "  --cuda         build CUDA image based on nvidia/cuda:13.2.1-base-ubuntu24.04"
    echo
    echo "example:"
    echo "  $0 -p http://192.168.xxx.xxx:7890"
    echo "  $0 -p http://192.168.xxx.xxx:7890 --cuda"
}

proxy=""
cuda=0
while [[ $# -gt 0 ]]; do
    case "$1" in
    -p)
        if [[ $# -lt 2 || "$2" == -* ]]; then
            help
            exit 1
        fi
        proxy="$2"
        shift 2
        ;;
    --cuda)
        cuda=1
        shift
        ;;
    -h|--help)
        help
        exit 0
        ;;
    *)
        echo "unknown option: $1" >&2
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

base_image="ubuntu:22.04"
tag="yyuze_env"
if [ "${cuda}" -eq 1 ]; then
    base_image="nvidia/cuda:13.2.1-base-ubuntu24.04"
    tag="yyuze_env_cuda"
fi

if [ -n "${SUDO_USER}" ] && [ "${SUDO_USER}" != "root" ]; then
    host_user="${SUDO_USER}"
    host_uid="${SUDO_UID:-$(id -u "${host_user}")}"
    host_gid="${SUDO_GID:-$(id -g "${host_user}")}"
else
    host_user="$(id -un)"
    host_uid="$(id -u)"
    host_gid="$(id -g)"
fi

if [ "${host_user}" = "root" ]; then
    user_home="/root"
else
    user_home="/home/${host_user}"
fi

docker build \
--build-arg BASE_IMAGE="${base_image}" \
--build-arg PROXY="${proxy}" \
--build-arg HOST_USER="${host_user}" \
--build-arg HOST_UID="${host_uid}" \
--build-arg HOST_GID="${host_gid}" \
--build-arg USER_HOME="${user_home}" \
-f ${PWD}/Dockerfile \
-t "${tag}" \
.
