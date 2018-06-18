#!/bin/sh
#set -x

# build config variables
MIN_IOS_VERSION="10.0"

#PLATFORM_ARCH_LIST=("x86_64")
PLATFORM_ARCH_LIST=("armv7s" "armv7" "arm64" "x86_64" "i386")

PLATFORM_PREFIX=`pwd`/output


#build environment variables
PLATFORM_INCLUDE_DIR=$PLATFORM_PREFIX/include
PLATFORM_LIB_DIR=$PLATFORM_PREFIX/lib
PLATFORM_STAGE_DIR=$PLATFORM_PREFIX/stage

PLATFORM_CONFIG_FLAGS="--quiet --enable-silent-rules"

mkdir -p "${PLATFORM_INCLUDE_DIR}"
mkdir -p "${PLATFORM_LIB_DIR}"
mkdir -p "${PLATFORM_STAGE_DIR}"
mkdir -p "$PLATFORM_STAGE_DIR"


#SDK_IOS_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
