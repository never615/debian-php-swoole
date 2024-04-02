在项目根目录下执行.

debian-php-swoole:

docker build -t never615/debian-php-swoole:arm64 -f ./Dockerfile .


docker build -t never615/debian-php-swoole:arm64-4.8-php8.2 -f ./Dockerfile_4.8_php8.2 .
docker push never615/debian-php-swoole:arm64_4.8_php8.2


