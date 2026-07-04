ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ARG PROXY
ARG HOST_USER=root
ARG HOST_UID
ARG HOST_GID
ARG NODE_MAJOR=24
ARG BASH_CONFIGS_REPO=https://github.com/yyuze/bash-configs.git

WORKDIR /root

# Install apt packages
RUN if [ x"$(arch 2>/dev/null)" = x"aarch64" ]; then \
    . /etc/os-release && \
    echo "replaced apt source list" && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${VERSION_CODENAME} main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${VERSION_CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${VERSION_CODENAME}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${VERSION_CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
fi

RUN apt update && apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN apt install -y --fix-missing \
    libpcap-dev libwebsocketpp-dev libbluetooth-dev \
    libmodbus-dev makeself git-lfs curl iputils-ping \
    net-tools iproute2 traceroute vim ninja-build \
    locales software-properties-common libopenjp2-7-dev \
    libboost-all-dev jq libfuse2 fuse zstd g++ cmake \
    sudo python3-pip wget unzip sshpass openssh-server \
    tmux

RUN if [ x"$(arch 2>/dev/null)" = x"x86_64" ]; then \
    apt-get update && apt-get install -y g++-12-aarch64-linux-gnu gcc-12-aarch64-linux-gnu; \
fi

# Install Node.js
RUN export http_proxy="${PROXY}" && \
    export https_proxy="${PROXY}" && \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y nodejs && \
    node --version && \
    npm --version

# Install Codex CLI
RUN export http_proxy="${PROXY}" && \
    export https_proxy="${PROXY}" && \
    export HTTP_PROXY="${PROXY}" && \
    export HTTPS_PROXY="${PROXY}" && \
    if [ -n "${PROXY}" ]; then \
        npm --proxy="${PROXY}" --https-proxy="${PROXY}" install -g @openai/codex; \
    else \
        npm install -g @openai/codex; \
    fi && \
    codex --version

# Enable sshd
RUN mkdir /run/sshd && \
    echo 'root:123456' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""

# Add host user
ARG USER_HOME=/root

RUN host_user="${HOST_USER:-root}" && \
    if [ "${host_user}" != "root" ]; then \
        if [ -z "${HOST_UID}" ] || [ -z "${HOST_GID}" ]; then \
            echo "HOST_UID and HOST_GID are required when HOST_USER is not root" >&2; \
            exit 1; \
        fi && \
        if ! getent group "${HOST_GID}" >/dev/null 2>&1; then \
            groupadd --gid "${HOST_GID}" "${host_user}"; \
        fi && \
        if ! id "${host_user}" >/dev/null 2>&1; then \
            useradd --uid "${HOST_UID}" --gid "${HOST_GID}" -m "${host_user}" -s "/bin/bash" -p "$(openssl passwd -6 123456)"; \
        fi && \
        echo "${host_user} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${host_user}" && \
        chmod 0440 "/etc/sudoers.d/${host_user}"; \
    fi

# Install user configs from bash-configs
RUN export http_proxy="${PROXY}" && \
    export https_proxy="${PROXY}" && \
    git -c http.proxy="${PROXY}" clone --depth 1 "${BASH_CONFIGS_REPO}" /opt/bash-configs && \
    host_user="${HOST_USER:-root}" && \
    user_home="$(getent passwd "${host_user}" | cut -d: -f6)" && \
    user_group="$(id -gn "${host_user}")" && \
    install -m 0644 /opt/bash-configs/tmux.conf "${user_home}/.tmux.conf" && \
    install -m 0644 /opt/bash-configs/vimrc "${user_home}/.vimrc" && \
    chown "${host_user}:${user_group}" "${user_home}/.tmux.conf" "${user_home}/.vimrc"

WORKDIR ${USER_HOME}

# Install rust
RUN export http_proxy="${PROXY}" && \
    export https_proxy="${PROXY}" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup update

EXPOSE 22

CMD ["/bin/bash"]
