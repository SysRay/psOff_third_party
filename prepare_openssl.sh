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
PERL_INTERPRETER="perl";

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

case "$(uname -s)" in
  Linux*)
    CONFIG_TARGET="linux-x86_64";
    ;;
  MINGW*|MSYS*)
    CONFIG_TARGET="VC-WIN64A";
    PERL_INTERPRETER="/c/Strawberry/perl/bin/perl";
    ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2;
    exit 1;
    ;;
esac

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

if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)";
elif [[ -n "${NUMBER_OF_PROCESSORS:-}" ]]; then
    JOBS="$NUMBER_OF_PROCESSORS";
else
    JOBS=4;
fi

MAKE_PROG="make";
if [[ "$CONFIG_TARGET" == "VC-WIN64A" ]]; then
  MAKE_PROG="/c/jom/jom.exe";
  JOBS="/j$JOBS /S";
else
  JOBS="-j$JOBS";
fi

(
  cd "$REPO_DIR";
  "$PERL_INTERPRETER" Configure "$CONFIG_TARGET" \
      "${CONFIGURE_FLAGS[@]}" \
      "${BUILD_TYPE}" \
      --prefix="$INSTALL_PREFIX" \
      --openssldir="$INSTALL_PREFIX/ssl";

  "$MAKE_PROG" "$JOBS";
  "$MAKE_PROG" install_sw;
)
