#!/bin/bash

. ./build_config.sh
. ./build_helpers.sh

#set -x #echo on

LIB_NAME=libstorj
LIB_VERSION=496dcf78a801cb026c1b3f9f3fa97550bed4d2b7

OUTPUT_LIB_NAME=$PLATFORM_LIB_DIR/$LIB_NAME.a

STAGE_DIR=$PLATFORM_STAGE_DIR

BUILDS_FOR_ARCH=()

build_universal_library() {

	download_if_needed

    cd $STAGE_DIR/$LIB_NAME-$LIB_VERSION

	./autogen.sh

	for ARCH in "${PLATFORM_ARCH_LIST[@]}"; do
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
        wget https://github.com/Storj/libstorj/archive/496dcf78a801cb026c1b3f9f3fa97550bed4d2b7.zip && \
		mv 496dcf78a801cb026c1b3f9f3fa97550bed4d2b7.zip "${LIB_NAME}_496dcf78a801cb026c1b3f9f3fa97550bed4d2b7.zip"

        unzip "${LIB_NAME}_496dcf78a801cb026c1b3f9f3fa97550bed4d2b7.zip"
        mv $STAGE_DIR/${LIB_NAME}_496dcf78a801cb026c1b3f9f3fa97550bed4d2b7 $LIB_NAME-$LIB_VERSION
    fi
}

build_for_architecture() {
	PLATFORM=$1
    ARCH=$2
    HOST=$3

	PREFIX="$STAGE_DIR/build/$ARCH"
	BUILDS_FOR_ARCH+="$PREFIX/lib/$LIB_NAME.a "

	SDKPATH=`xcrun -sdk $PLATFORM --show-sdk-path`

	cd $STAGE_DIR/$LIB_NAME-$LIB_VERSION
	make clean
	make distclean

	CLANG=`xcrun -sdk $PLATFORM -find clang`

	COMMONFLAGS="-arch ${ARCH} \
				-isysroot ${SDKPATH} \
				--sysroot ${SDKPATH}"

	CFLAGS="$COMMONFLAGS -I${PREFIX}/include -I${SDKPATH}/usr/include \
			-mlinker-version=253.9 \
			-pipe \
			-O0" 

	LDFLAGS="$COMMONFLAGS -L${PREFIX}/lib -L${SDKPATH}/usr/lib"

	#export PATH="$(pwd)/depends/toolchain/build/bin:${PATH}" && \
	#PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
	#CC=clang \
	#CXX=clang++ \
	#CFLAGS="-target x86_64-apple-darwin11 -isysroot $(pwd)/depends/MacOSX10.11.sdk -mmacosx-version-min=10.8 -mlinker-version=253.9 -pipe -I$(pwd)/depends/build/x86_64-apple-darwin11/include" \
	#LDFLAGS="-L$(pwd)/depends/toolchain/build/lib -L$(pwd)/depends/MacOSX10.11.sdk/usr/lib -L$(pwd)/depends/build/x86_64-apple-darwin11/lib -Wl,-syslibroot $(pwd)/depends/MacOSX10.11.sdk" \
	#./configure --with-pic --host="x86_64-apple-darwin11" --enable-static --disable-shared --prefix=$(pwd)/depends/build/x86_64-apple-darwin11

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
	PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
	LDFLAGS="$LDFLAGS" \
	CCASFLAGS="$CFLAGS" \
	CFLAGS="$CFLAGS" \
	CXXFLAGS="$CFLAGS" \
	M4FLAGS="$CFLAGS" \
	CPPFLAGS="$CFLAGS" \
		--prefix=${PREFIX} \
		--host=${HOST} \
		--enable-static \
		--with-pic \
		$PLATFORM_CONFIG_FLAGS \
	&& xcrun -sdk $PLATFORM make clean --quiet \
    && xcrun -sdk $PLATFORM make -j 16 install

	cp -r $PREFIX/include/* "${PLATFORM_INCLUDE_DIR}/"
}

build_universal_library

echo "Finished with $OUTPUT_LIB_NAME"
