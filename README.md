# docker-kong
使用docker-compose一键部署kong api网关服务，在使用此项目之前，请确保您已安装[docker-compose](https://docs.docker.com/compose/install/)

## Usage
由于docker-compose在启动服务的时候，无法确保容器A一定会在容器B运行完成之后执行。虽然可以通过volumes_for、depends_on以及link等配置来控制容器的执行顺序，但是这种方式只能保证容器A在容器B启动之后执行，而不能保证容器A能在容器B完全运行完命令之后才执行，[详情请查看官方文档](https://docs.docker.com/compose/startup-order/)。为了解决这一问题，统一采用kong.sh脚本来控制服务的启动、更新和关闭。kong.sh含有健康检测的功能，如果服务未完全启动，会进行重试操作。

### 添加环境配置文件
```bash
cp .env.example .env
```

### 服务启动或更新
```bash
./kong.sh start postgres
```

> 注：在首次启动服务的时候，可能会出现多次重试的情况，这个是正常现象，耐心等待即可，原因已经在上面说明。

### 服务关闭
```bash
./kong.sh stop postgres
```

## 配置存储层

### 使用postgres容器
1、修改.env文件
```ini
KONG_DATABASE_TYPE=postgres
KONG_DATABASE_HOST=kong-database
```

2、启动服务
```bash
./kong.sh start postgres
```

### 使用cassandra容器
1、修改.env文件
```ini
KONG_DATABASE_TYPE=cassandra
KONG_DATABASE_HOST=kong-database
```

2、启动服务
```bash
./kong.sh start cassandra
```

### 使用外部数据库服务
1、修改.env文件
```ini
KONG_DATABASE_TYPE=外部数据库服务类型，postgres或cassandra
KONG_DATABASE_HOST=外部数据库服务地址
```

2、启动服务
```bash
./kong.sh start external
```

> 注：数据库服务必须使用默认端口，即postgres使用5432端口，cassandra使用9042作为CQL端口
