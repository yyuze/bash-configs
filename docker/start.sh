#!/bin/bash

if [ "$EUID" -ne 0 ];
then
    echo "ERROR: root privilegde is required"
    exit 1
fi

help() {
    echo "usage: $0 -d DIR"
    echo
    echo "options:"
    echo "  -d DIR      abs path of a direcotry, which will be shared with the docker"
    echo
    echo "example:"
    echo "  $0 -d /path/to/shared"
}

shared_path=""
while getopts ":d:" opt; do
    case $opt in
    d)
        shared_path="$OPTARG"
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

if [ -z "${shared_path}" ]; then
    echo "shared path is required"
    help
    exit 1
fi

if [ ! -d ${shared_path} ]; then
    echo "${shared_path} directory is not exist"
    exit 1
fi

if [ $(realpath ${shared_path}) != ${shared_path} ]; then
    echo "${shared_path} should be absolute"
    exit 1
fi

find_available_port() {
    local start_port=10000
    local end_port=65535
    local max_attempts=100
    local attempt=0

    local port_range=$((end_port - start_port + 1))

    while [[ $attempt -lt $max_attempts ]]; do
        local random_port=$((RANDOM % port_range + start_port))
        if ! ss -tuln | grep -q ":${random_port}\b"; then
            echo ${random_port}
            return 0
        fi
        attempt=$((attempt + 1))
    done

    echo "get port failed, max attempts arrived: ${max_attempts}" >&2
    return 1
}

# allocate port
if ! ssh_port=$(find_available_port); then
    exit 1
fi

user=""
home=""
if [ -z "${SUDO_USER}" ]; then
    user="root"
    home="/root"
else
    user="root"
    user="${SUDO_USER}"
    home="/home/${user}"
fi

# start docker container
container_id=$(
    docker run \
    -d \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    -v ${shared_path}:${home}/$(basename ${shared_path}) \
    -p "0.0.0.0:${ssh_port}:22" \
    yyuze_env:latest \
    "sudo" "/usr/sbin/sshd" "-D"
)

if [ $? == 0 ]; then
    echo "Container created success"
    echo "Id: ${container_id}"
    echo "You can access it with ssh:"
    echo "  ssh ${user}@localhost -p ${ssh_port} # password 123456"
else
    echo "Docker container created failed"
fi
