# 使用官方 Python 作为基础镜像
FROM ubuntu:22.04

# 设置工作目录
WORKDIR /app

# 复制当前目录下的所有文件到容器的 /app 目录
COPY . .

# 安装依赖
RUN apt-get update

# 设置容器启动时执行的命令
CMD ["/app/hello"]

