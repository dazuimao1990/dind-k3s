#!/bin/bash

[[ $DEBUG ]] && set -x


RED='\033[0;31m'
GREEN='\033[32;1m'
NC='\033[0m' # No Color


# 我可以在这里做些什么
# 这里的操作会在容器生成之后， dockerd k3s 进程启动之前生效

# 根据环境变量，为 dockerd 进程追加参数 , 比如启动容器时添加 -e DOCKER_ARGS="--log-level=debug"
function dockerdArgs() {
    echo -e "${GREEN} Will append args for dockerd ${DOCKER_ARGS} ${NC}"
    # 匹配 dockerd 一行，在结尾追加环境变量值，注意，环境变量名前面有个空格
    sed -i "/dockerd/ s/$/ "${DOCKER_ARGS}"/" /etc/supervisor/conf.d/dind.conf
}

# 处理 k3s 配置文件，如果不存在，则复制一份到指定的目录中
function configK3s() {
local K3S_DATA_DIR=${K3S_DATA_DIR:-/app/k3s}
local K3S_CONFIG=${K3S_CONFIG:-config.yaml}
local KUBE_CONFIG=${KUBE_CONFIG:-/app/k3s/k3s.yaml}

if [ ! -f ${K3S_DATA_DIR}/${K3S_CONFIG} ];then
    echo -e "${GREEN} Local k3s cluster config: ${K3S_DATA_DIR}/${K3S_CONFIG} ${NC}"
    cp /app/utils/k3s-conf.yaml  ${K3S_DATA_DIR}/${K3S_CONFIG}
fi
# 创建别名，让 kubectl 可以找到合适的配置文件
echo -e "alias kubectl='kubectl --kubeconfig ${KUBE_CONFIG}'" > ~/.bashrc
}

if [ ! -n ${DOCKER_ARGS} ];then
    dockerdArgs
fi

configK3s 

exec $@ # 继续执行后续 CMD 传入的命令