# dind-k3s

#### 介绍
利用 docker in docker （dind）实现在一个容器中启动可用的 k3s 集群。进程管理利用 supervisor 实现。

#### 软件架构
软件架构说明

```bash
.
├── Dockerfile              
├── README.en.md
├── README.md
├── docker-entrypoint.sh
└── utils
    ├── daemon.json         # dockerd 配置文件
    ├── dind.conf           # dockerd k3s 的进程管理配置文件
    ├── k3s-conf.yaml       # k3s 配置文件
    └── supervisord.conf    # supervisord 配置文件
```

#### 构建镜像

```bash
docker build -t dind-k3s .
```

#### 使用说明

1.  启动容器

> 需要注意的是，如果你在 MacOS 上使用 Docker Desktop 启动这个容器，请将 `/var/lib/docker` 的持久化去掉，否则会报错目录读写权限不足，导致 dind 无法启动。目前我也不知道为什么，明明已经在 `安全性与隐私` 中添加了文件和文件夹权限。😣


```bash
sudo docker run -d \
--name=my-dind-k3s \
--privileged \
-v ~/data/docker:/var/lib/docker \
-v ~/data/k3s:/app/k3s \
dind-k3s
```

2. 进入容器

```bash
docker exec -ti my-dind-k3s bash
```

3. 验证 docker 功能和 k3s 集群功能

```bash
docker info

kubectl --kubeconfig /app/k3s/k3s.yaml get node 
```


