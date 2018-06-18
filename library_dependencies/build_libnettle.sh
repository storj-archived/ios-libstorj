#!/bin/bash

. ./build_config.sh
. ./build_helpers.sh

#set -x #echo on

LIB_NAME=libnettle
LIB_VERSION=3.3

SECONDARY_LIB_NAME=libhogweed

OUTPUT_LIB_NAME=$PLATFORM_LIB_DIR/$LIB_NAME.a
OUTPUT_SECONDARY_LIB_NAME=$PLATFORM_LIB_DIR/$SECONDARY_LIB_NAME.a

STAGE_DIR=$PLATFORM_STAGE_DIR

BUILDS_FOR_ARCH=()
SECONDAY_BUILDS_FOR_ARCH=()

build_universal_library() {

	download_if_needed

    cd $STAGE_DIR/$LIB_NAME-$LIB_VERSION

	for ARCH in "${PLATFORM_ARCH_LIST[@]}"; do
        HOST=$(host_for_arch $ARCH)
        PLATFORM=$(platform_for_arch $ARCH)
        echo "############################################"
        echo "Building $LIB_NAME for $PLATFORM $ARCH $HOST"
        echo "############################################"
        build_for_architecture $PLATFORM $ARCH $HOST
    done

	lipo -create -output $OUTPUT_LIB_NAME $(echo $BUILDS_FOR_ARCH)
	lipo -create -output $OUTPUT_SECONDARY_LIB_NAME $(echo $SECONDAY_BUILDS_FOR_ARCH)

    verify_binary_architectures $OUTPUT_LIB_NAME
	verify_binary_architectures $OUTPUT_SECONDARY_LIB_NAME
}

download_if_needed() {
    cd $STAGE_DIR

    if [ ! -e $LIB_NAME-$LIB_VERSION ]; then
        wget http://www.lysator.liu.se/~nisse/archive/nettle-${LIB_VERSION}.tar.gz
        tar xfj "nettle-${LIB_VERSION}.tar.gz"
        mv nettle-$LIB_VERSION $LIB_NAME-$LIB_VERSION 
    fi
}

build_for_architecture() {
	PLATFORM=$1
    ARCH=$2
    HOST=$3

	PREFIX="$STAGE_DIR/build/$ARCH"
	BUILDS_FOR_ARCH+="$PREFIX/lib/$LIB_NAME.a "
	SECONDAY_BUILDS_FOR_ARCH+="$PREFIX/lib/$SECONDARY_LIB_NAME.a "

	SDKPATH=`xcrun -sdk $PLATFORM --show-sdk-path`

	COMMONFLAGS="-arch ${ARCH} \
				-fembed-bitcode \
				-pipe \
				-O0 \
				-isysroot ${SDKPATH} "

	cd $STAGE_DIR/$LIB_NAME-$LIB_VERSION
	make clean
	make distclean

	CLANG=`xcrun -sdk $PLATFORM -find clang`

	CFLAGS="$COMMONFLAGS -I${PREFIX}/include -I${SDKPATH}/usr/include" 

	./configure \
	CC=`xcrun -sdk $PLATFORM -find cc` \
	CXX=`xcrun -sdk $PLATFORM -find c++` \
	AS=`xcrun -sdk $PLATFORM -find as` \
	LD=`xcrun -sdk $PLATFORM -find ld` \
	AR=`xcrun -sdk $PLATFORM -find ar` \
	NM=`xcrun -sdk $PLATFORM -find nm` \
	CPP="${CLANG} -E" \
	CXXCPP="${CLANG} -E" \
	RANLIB=`xcrun -sdk $PLATFORM -find ranlib` \
	LIBTOOL=`xcrun -sdk $PLATFORM -find libtool` \
	CC_FOR_BUILD="${CLANG} -isysroot / -I/usr/include" \
	LDFLAGS="$COMMONFLAGS -L${PREFIX}/lib -L${SDKPATH}/usr/lib" \
	CCASFLAGS="$CFLAGS" \
	CFLAGS="$CFLAGS" \
	CXXFLAGS="$CFLAGS" \
	M4FLAGS="$CFLAGS" \
	CPPFLAGS="$CFLAGS" \
		--prefix=${PREFIX} \
		--host=${HOST} \
		--enable-static \
		--disable-assembler \
		--disable-arm-neon \
		$PLATFORM_CONFIG_FLAGS 

	echo "    🛠  Build..."
	make -j16
	make install
	make clean

	cp -r $PREFIX/include/* "${PLATFORM_INCLUDE_DIR}/"
}

build_universal_library

echo "Finished with $OUTPUT_LIB_NAME"
