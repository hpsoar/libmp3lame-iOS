#!/bin/bash
## Mini-Xcode: XCode 5

MIN_VERSION="6.0"

# set default output folder is build
OUTPUT_FOLDER=${PREFIX-build}

# set default compiler
CC=${CC-$(xcrun --find gcc)}
LIPO=${LIPO-$(xcrun --find lipo)}

XCODE_PATH=$(xcode-select -print-path)

# make output folder
mkdir -p $OUTPUT_FOLDER

function build_lame()
{
    make distclean

    # SDK must lower case
    SDK_ROOT=$(xcrun --sdk $(echo ${SDK} | tr '[:upper:]' '[:lower:]') --show-sdk-path)

    ./configure \
        CFLAGS="-arch ${PLATFORM} -pipe -std=c99 -isysroot ${SDK_ROOT} -miphoneos-version-min=${MIN_VERSION} -fembed-bitcode" \
        --host="$HOST" \
        --enable-static \
        --disable-decoder \
        --disable-frontend \
        --disable-debug \
        --disable-dependency-tracking

    make

    cp "libmp3lame/.libs/libmp3lame.a" "${OUTPUT_FOLDER}/libmp3lame-${PLATFORM}.a"
}

# build simulator version
SDK="iPhoneSimulator"
PLATFORM="i686"
build_lame

HOST="i686-apple-darwin13.1.0"
SDK="iPhoneSimulator"
PLATFORM="x86_64"
build_lame

# build device version
SDK="iPhoneOS"
PLATFORM="armv7"
build_lame

PLATFORM="armv7s"
build_lame

PLATFORM="arm64"
build_lame

# remove old libmp3lame.a or lipo will failed
OUTPUT_LIB=${OUTPUT_FOLDER}/libmp3lame.a
if [ -f $OUTPUT_LIB ]; then
    rm $OUTPUT_LIB
fi

${LIPO} -create ${OUTPUT_FOLDER}/* -output ${OUTPUT_LIB}
