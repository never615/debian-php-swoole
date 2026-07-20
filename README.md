在项目根目录下执行.

debian-php-swoole:

docker build -t never615/debian-php-swoole:arm64 -f ./Dockerfile .


docker build -t never615/debian-php-swoole:arm64-4.8-php8.2 -f ./Dockerfile_4.8_php8.2 .
docker push never615/debian-php-swoole:arm64_4.8_php8.2


## 麒麟 V10 SP3 ARM64 基础镜像

这条构建链不继承 `phpswoole/swoole`，而是从麒麟 V10 SP3 ARM64 rootfs 开始，
在麒麟用户态中从源码编译 PHP 8.2.5、Swoole 5.0.3 和业务所需 PHP 扩展。
运行层同时固定安装 Composer 2.8.12（校验 SHA-256）、Git/SSH/解压工具，并创建
应用镜像需要的 `www-data` 账户。

先在已安装的麒麟 V10 SP3 ARM64 主机中生成 rootfs：

```bash
sudo OUTPUT=/tmp/kylin-v10-sp3-2403-arm64-rootfs.tar \
  ./build-kylin-v10-rootfs.sh
```

把 tar 复制到构建机后导入并构建：

```bash
docker import --platform linux/arm64 \
  /tmp/kylin-v10-sp3-2403-arm64-rootfs.tar \
  kylin:v10-sp3-2403-arm64

docker build --platform linux/arm64 \
  -f Dockerfile_kylin_5.0.3_php8.2 \
  -t mallto/debian-php-swoole:kylin-v10-sp3-arm64-5.0.3-php8.2 .
```

验证容器内的操作系统和运行时：

```bash
docker run --rm mallto/debian-php-swoole:kylin-v10-sp3-arm64-5.0.3-php8.2 \
  sh -lc 'cat /etc/os-release; php -v; php --ri swoole | head -20'
```

## 麒麟 V10 SP3 2403 AMD64（ACR 动态构建）

`Dockerfile_kylin_amd64_5.0.3_php8.2` 直接使用麒麟 V10 SP3 2403 的
`linux/amd64` manifest digest，构建和运行阶段都会校验 `x86_64`、麒麟产品标识和
`kylin-release`，然后在麒麟用户态中从源码构建 PHP/Swoole。

ACR 构建规则建议固定为：

- 构建架构：`linux/amd64`
- 构建上下文：`/`
- Dockerfile：`Dockerfile_kylin_amd64_5.0.3_php8.2`
- 镜像 tag：`kylin-v10-sp3-amd64-5.0.3-php8.2`

本地或 ACR 外部预检命令：

```bash
docker build --platform linux/amd64 \
  -f Dockerfile_kylin_amd64_5.0.3_php8.2 \
  -t registry.cn-shenzhen.aliyuncs.com/mallto/debian-php-swoole:kylin-v10-sp3-amd64-5.0.3-php8.2 .

docker run --rm --platform linux/amd64 \
  registry.cn-shenzhen.aliyuncs.com/mallto/debian-php-swoole:kylin-v10-sp3-amd64-5.0.3-php8.2 \
  sh -lc 'uname -m; cat /etc/.productinfo; php -v; php --ri swoole | head -20'
```
