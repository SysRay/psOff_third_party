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

if [[ -d "$REPO_DIR/.git" ]]; then
    echo "==> $REPO_DIR already exists, skipping clone";
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
        CONFIG_TARGET="mingw64";
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

JOBS="${JOBS:-}";
if [[ -z "$JOBS" ]]; then
    if command -v nproc >/dev/null 2>&1; then
        JOBS="$(nproc)";
    elif [[ -n "${NUMBER_OF_PROCESSORS:-}" ]]; then
        JOBS="$NUMBER_OF_PROCESSORS";
    else
        JOBS=4;
    fi
fi

MAKE_BIN="make";
if ! command -v make >/dev/null 2>&1; then
    MAKE_BIN="mingw32-make";
fi

(
    cd "$REPO_DIR";
    "$PERL_INTERPRETER" Configure "$CONFIG_TARGET" \
        "${CONFIGURE_FLAGS[@]}" \
        "${BUILD_TYPE}" \
        --prefix="$INSTALL_PREFIX" \
        --openssldir="$INSTALL_PREFIX/ssl";

    "$MAKE_BIN" -j"$JOBS";
    "$MAKE_BIN" install_sw;
)
