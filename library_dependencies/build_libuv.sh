#!/bin/sh
. ./build_config.sh
. ./build_helpers.sh

LIB_NAME=libuv
LIB_VERSION=1.9.1

OUTPUT_LIB_NAME=$PLATFORM_LIB_DIR/$LIB_NAME.a

STAGE_DIR=$PLATFORM_STAGE_DIR

BUILDS_FOR_ARCH=()

build_universal_library() {
    download_if_needed

    cd $STAGE_DIR/$LIB_NAME-$LIB_VERSION

    sh autogen.sh

    for ARCH in "${PLATFORM_ARCH_LIST[@]}" 
    do
        HOST=$(host_for_arch $ARCH)
        PLATFORM=$(platform_for_arch $ARCH)
        echo "############################################"
        echo "Building $LIB_NAME for $PLATFORM $ARCH $HOST"
        echo "############################################"
        build_for_architecture $PLATFORM $ARCH $HOST
    done

    lipo -create -output $OUTPUT_LIB_NAME $(echo $BUILDS_FOR_ARCH)

    verify_binary_architectures $OUTPUT_LIB_NAME
}

download_if_needed() {
    cd $STAGE_DIR

    if [ ! -e $LIB_NAME-$LIB_VERSION ]; then
        wget "http://dist.libuv.org/dist/v$LIB_VERSION/libuv-v$LIB_VERSION.tar.gz"
        tar -xzf libuv-v$LIB_VERSION.tar.gz
        mv libuv-v$LIB_VERSION $LIB_NAME-$LIB_VERSION 
    fi
}

build_for_architecture() {
    PLATFORM=$1
    ARCH=$2
    HOST=$3

    SDKPATH=`xcrun -sdk $PLATFORM --show-sdk-path`
    PREFIX=$STAGE_DIR/build/$ARCH
    BUILDS_FOR_ARCH+="$PREFIX/lib/$LIB_NAME.a "

    BUILD_C_FLAGS="-arch $ARCH -isysroot $SDKPATH -Os -pipe -no-cpp-precomp -miphoneos-version-min=$MIN_IOS_VERSION"

    ./configure \
    CC=`xcrun -sdk $PLATFORM -find cc` \
    CXX=`xcrun -sdk $PLATFORM -find c++` \
    CPP=`xcrun -sdk $PLATFORM -find cc`" -E" \
    LD=`xcrun -sdk $PLATFORM -find ld` \
    AR=`xcrun -sdk $PLATFORM -find ar` \
    NM=`xcrun -sdk $PLATFORM -find nm` \
    NMEDIT=`xcrun -sdk $PLATFORM -find nmedit` \
    LIBTOOL=`xcrun -sdk $PLATFORM -find libtool` \
    LIPO=`xcrun -sdk $PLATFORM -find lipo` \
    OTOOL=`xcrun -sdk $PLATFORM -find otool` \
    RANLIB=`xcrun -sdk $PLATFORM -find ranlib` \
    STRIP=`xcrun -sdk $PLATFORM -find strip` \
    CFLAGS="$BUILD_C_FLAGS" \
    CPPFLAGS="$BUILD_C_FLAGS" \
    CXXFLAGS="$BUILD_C_FLAGS" \
    LDFLAGS="-arch $ARCH -headerpad_max_install_names -Os -Wl -dead_strip -miphoneos-version-min=$MIN_IOS_VERSION" \
    --host=$HOST \
    --prefix=$PREFIX \
    --enable-static \
    $PLATFORM_CONFIG_FLAGS \
    && xcrun -sdk $PLATFORM make clean --quiet \
    && xcrun -sdk $PLATFORM make -j 16 install

    cp -r $PREFIX/include/* "${PLATFORM_INCLUDE_DIR}/"
}


build_universal_library

echo "Finished with $OUTPUT_LIB_NAME"
