FROM ubuntu:20.10

LABEL auther="guox@goodrain.com"

WORKDIR /app

# 安装必要的依赖
# 安装 docker k3s kubectl
# 根据构建环境的 CPU 架构区分下载地址
RUN sed -i -e 's/ports.ubuntu.com/mirrors.aliyun.com/g' \
    -e 's/archive.ubuntu.com/mirrors.aliyun.com/g' \
    -e 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt update \
    && apt install -y supervisor iptables wget vim \
    && rm -rf /var/lib/apt/lists/*

RUN Arch="$(arch)"; \
	case "$Arch" in \
		'x86_64') \
			docker_url='https://download.docker.com/linux/static/stable/x86_64/docker-20.10.11.tgz'; \
            k3s_url="https://github.com/rancher/k3s/releases/download/v1.22.3+k3s1/k3s" \
            kubectl_url="https://storage.googleapis.com/kubernetes-release/release/v1.22.3/bin/linux/amd64/kubectl" \
			;; \
		'aarch64') \
			docker_url='https://download.docker.com/linux/static/stable/aarch64/docker-20.10.11.tgz'; \
            k3s_url="https://github.com/rancher/k3s/releases/download/v1.22.3+k3s1/k3s-arm64" \
            kubectl_url="https://storage.googleapis.com/kubernetes-release/release/v1.22.3/bin/linux/arm64/kubectl" \
			;; \
	esac \
    && wget -O docker.tgz "$docker_url" \
	&& tar xzf docker.tgz --strip-components 1 --directory /usr/local/bin/ \
	&& rm docker.tgz \
    && mkdir -p /etc/docker \
    && wget -O /usr/local/bin/k3s "$k3s_url" \
    && wget -O /usr/local/bin/kubectl "$kubectl_url" 

# 文件的变更是最频繁的变更，把拷贝文件的过程放在安装软件包、下载大体积资源的后面，可以更合理的利用镜像构建缓存，极大的节约构建时间
ADD . .

RUN chmod +x /usr/local/bin/k3s /usr/local/bin/kubectl /app/docker-entrypoint.sh \
    && mkdir -p /app/logs/ /app/k3s \
    && cp utils/dind.conf /etc/supervisor/conf.d/dind.conf \
    && cp utils/daemon.json /etc/docker/ \
    && cp utils/k3s-conf.yaml /app/k3s/config.yaml \
    && cp utils/supervisord.conf /etc/supervisor/supervisord.conf
   

VOLUME [ "/var/lib/docker", "/app/k3s" ]
 
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
CMD ["/usr/bin/supervisord"]