#!/bin/bash
set -euo pipefail;

if [[ $# -lt 1 || -z "$1" ]]; then
  echo "Usage: $0 <install-prefix>" >&2;
  exit 1;
fi

INSTALL_PREFIX="$1";
OPENSSL_REF="openssl-3.6.4";
REPO_DIR="./projects/OpenSSL";
BUILD_TYPE="--release";

if [[ "$2" == "Debug" ]]; then
  BUILD_TYPE="--debug";
fi

mkdir -p "$INSTALL_PREFIX";
INSTALL_PREFIX="$(cd "$INSTALL_PREFIX" && pwd)";

if [ -d "$REPO_DIR/.git" ]; then
  cd "$REPO_DIR";
  git fetch --depth=1 origin;
  git reset --hard $OPENSSL_REF;
  git gc --prune=now;
else
  mkdir -p "$(dirname "$REPO_DIR")";
  git clone --depth 1 --branch "$OPENSSL_REF" \
      https://github.com/openssl/openssl.git "$REPO_DIR";
fi

CONFIGURE_FLAGS=(
  shared
  no-tests
  no-apps
  no-docs
  no-engine
  no-dynamic-engine
  no-legacy
  no-deprecated
  no-comp
  no-idea
  no-mdc2
  no-rc5
  no-srp
  no-psk
  no-camellia
  no-cast
  no-seed
  no-whirlpool
  no-blake2
  no-siphash
  no-sm2
  no-sm3
  no-sm4
  no-async
  no-zlib
  no-ui-console
);

(
  cd "$REPO_DIR";
  perl Configure "linux-x86_64" \
      "${CONFIGURE_FLAGS[@]}" \
      "${BUILD_TYPE}" \
      --prefix="$INSTALL_PREFIX" \
      --openssldir="$INSTALL_PREFIX/ssl";

  make "-j$(nproc)";
  make install_sw;
)
