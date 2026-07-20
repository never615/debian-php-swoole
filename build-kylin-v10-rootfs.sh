#!/usr/bin/env bash

set -euo pipefail

ROOTFS_DIR="${ROOTFS_DIR:-/var/tmp/kylin-v10-sp3-arm64-rootfs}"
OUTPUT="${OUTPUT:-$PWD/kylin-v10-sp3-2403-arm64-rootfs.tar}"
RELEASEVER="${RELEASEVER:-V10}"

if [ "$(id -u)" -ne 0 ]; then
  echo "请在麒麟 V10 SP3 ARM64 主机上使用 root 或 sudo 运行此脚本。" >&2
  exit 1
fi

if [ "$(uname -m)" != "aarch64" ]; then
  echo "当前架构不是 aarch64，拒绝生成 ARM64 rootfs。" >&2
  exit 1
fi

if [ -e "${ROOTFS_DIR}" ] && [ -n "$(find "${ROOTFS_DIR}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "ROOTFS_DIR 已存在且非空: ${ROOTFS_DIR}" >&2
  echo "请换一个空目录，或自行确认后清理旧目录。" >&2
  exit 1
fi

mkdir -p "${ROOTFS_DIR}/etc/pki/rpm-gpg" "$(dirname "${OUTPUT}")"
cp /etc/pki/rpm-gpg/RPM-GPG-KEY-kylin "${ROOTFS_DIR}/etc/pki/rpm-gpg/"

dnf -y \
  --installroot="${ROOTFS_DIR}" \
  --releasever="${RELEASEVER}" \
  --disablerepo=docker-ce-stable \
  --setopt=install_weak_deps=False \
  --setopt=tsflags=nodocs \
  install \
  basesystem filesystem setup glibc glibc-common bash coreutils \
  ca-certificates tzdata dnf rpm curl tar gzip xz bzip2 \
  findutils grep sed gawk which shadow-utils util-linux procps-ng \
  iproute hostname

chroot "${ROOTFS_DIR}" dnf clean all
find "${ROOTFS_DIR}/var/cache/dnf" -mindepth 1 -delete
find "${ROOTFS_DIR}/tmp" "${ROOTFS_DIR}/var/tmp" -mindepth 1 -delete
truncate -s 0 "${ROOTFS_DIR}/etc/machine-id"

tar --numeric-owner --xattrs --acls -C "${ROOTFS_DIR}" -cf "${OUTPUT}" .

echo "已生成: ${OUTPUT}"
echo "导入命令: docker import --platform linux/arm64 ${OUTPUT} kylin:v10-sp3-2403-arm64"
