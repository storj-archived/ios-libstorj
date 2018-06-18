#!/bin/sh

sh ./build_libmicrohttpd.sh && \
sh ./build_libjson-c.sh && \
sh ./build_libcurl.sh && \
sh ./build_libuv.sh && \
sh ./build_libgmp.sh && \
sh ./build_libnettle.sh && \
sh ./build_libstorj.sh

echo "SUCCESS BUILD ALL"
