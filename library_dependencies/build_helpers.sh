#!/bin/sh

host_for_arch() {
    ARCH=$1
    if [ "$1" = "i386" ]; then
        echo "i386-apple-darwin"
    elif [ "$1" = "x86_64" ]; then
        echo "x86_64-apple-darwin"
    else
        echo "arm-apple-darwin"
    fi
}

platform_for_arch() {
    ARCH=$1
    if [ "$1" = "i386" ] || [ "$1" = "x86_64" ]; then
        echo "iphonesimulator"
    else
        echo "iphoneos"
    fi
}

verify_binary_architectures() {
    LIB_FILE=$1
    echo "Verifying binary $LIB_FILE"
    if [ ! -e $LIB_FILE ]; then
        echo "$LIB_FILE does not exist"
        exit 1
    else
        BINARY_INFO=$(lipo -info $LIB_FILE)
        for ARCH in "${PLATFORM_ARCH_LIST[@]}"; do
            if ! [[ $BINARY_INFO == *$ARCH* ]]; then
                echo "Missing $ARCH in binary"
                exit 1
            fi
        done
    fi
}
