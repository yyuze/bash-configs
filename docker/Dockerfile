ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ARG PROXY
ARG HOST_USER
ARG HOST_UID
ARG HOST_GID
ARG NODE_MAJOR=24

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
    mkdir -p /opt/codex /usr/local/bin && \
    curl -fsSL https://chatgpt.com/codex/install.sh | \
        CODEX_HOME=/opt/codex CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR=/usr/local/bin sh && \
    codex --version

# Enable sshd
RUN mkdir /run/sshd && \
    echo 'root:123456' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""

# Add host user
ARG USER_HOME

RUN if ! getent group ${HOST_USER} >/dev/null 2>&1; then \
        groupadd --gid ${HOST_GID} ${HOST_USER}; \
    fi && \
    if ! id ${HOST_USER} >/dev/null 2>&1; then \
        useradd --uid ${HOST_UID} --gid ${HOST_GID} -m ${HOST_USER} -s "/bin/bash" -p $(openssl passwd -6 123456); \
    fi && \
    if ${HOST_USER} != "root"; then \
        echo "${HOST_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${HOST_USER}; \
    fi

WORKDIR ${USER_HOME}

# Install rust
RUN export http_proxy="${PROXY}" && \
    export https_proxy="${PROXY}" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup update

EXPOSE 22

CMD ["/bin/bash"]
