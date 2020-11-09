#!/bin/sh
set -ex
set -o functrace

CMAKE_BIN_URL_64=https://cmake.org/files/v3.6/cmake-3.6.3-Linux-x86_64.sh
CMAKE_BIN_URL_32=https://cmake.org/files/v3.6/cmake-3.6.3-Linux-i386.sh

function build_boost {
    mkdir -p boost
    cd boost
    export BOOST_PREFIX="$(pwd)"
    curl -L https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.bz2 | tar xfj -
    cd boost_1_66_0/
    BOOST_ROOT="$(pwd)"
    cd tools/build
    sh bootstrap.sh
    ./b2 ../../tools/bcp
    cd "${BOOST_ROOT}"
    # crc iterator and variant are only components required by libosmium
    dist/bin/bcp variant crc iterator "${BOOST_PREFIX}"
    # this would try to install all (and fail on binary components)
    # find libs -maxdepth 1 -type d | sed -e 's#libs/##' | xargs -I {} dist/bin/bcp {} "${BOOST_PREFIX}" || true
}

function build_cmake {
    if [ "x${AUDITWHEEL_ARCH}" == "xi686" ] ; then
        curl -o /tmp/cmake.sh "${CMAKE_BIN_URL_32}"
    else
        curl -o /tmp/cmake.sh "${CMAKE_BIN_URL_64}"
    fi
    (cd / && bash /tmp/cmake.sh --skip-license --prefix=/usr )
    cmake --version
}


if [ -f /project/cibuild_steps_done ] ; then
    exit 0
fi

. /project/multibuild/manylinux_utils.sh
. /project/multibuild/library_builders.sh

mkdir /project/pyosmium/contrib

ln -sf /project/pybind11 /project/pyosmium/contrib/pybind11
ln -sf /project/libosmium /project/pyosmium/contrib/libosmium
ln -sf /project/protozero /project/pyosmium/contrib/protozero

# install dependencies
#        if [ "$MB_ML_VER" == "1" ] ; then
#             yum install -y sparsehash-devel
#             build_cmake
#             build_boost
#         fi
#         if [ "$MB_ML_VER" == "2010" ] ; then
#             # cmake is already present in image
#             yum install -y sparsehash-devel expat-devel boost-devel
#         fi


yum install -y sparsehash-devel expat-devel boost-devel zlib-devel


# install bzip2
build_new_zlib
build_bzip2
build_cmake

touch /project/cibuild_steps_done
