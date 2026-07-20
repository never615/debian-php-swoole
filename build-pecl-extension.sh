#!/bin/sh

set -eu

if [ "$#" -lt 2 ]; then
  echo "usage: $0 EXTENSION VERSION [CONFIGURE_OPTIONS...]" >&2
  exit 2
fi

extension="$1"
version="$2"
shift 2
source_dir="/tmp/build-${extension}"

curl --fail --silent --show-error --location \
  --retry 5 --retry-delay 2 --retry-all-errors --connect-timeout 20 \
  "https://pecl.php.net/get/${extension}-${version}.tgz" \
  -o "/tmp/${extension}.tgz"
mkdir "${source_dir}"
tar -xzf "/tmp/${extension}.tgz" -C "${source_dir}" --strip-components=1
cd "${source_dir}"
phpize
./configure "$@"
make -j"$(nproc)"
make install
echo "extension=${extension}.so" > "${PHP_INI_DIR}/conf.d/20-${extension}.ini"
