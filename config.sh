#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

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
    if [ "x${PLAT}" == "xi686" ] ; then
        curl -o /tmp/cmake.sh "${CMAKE_BIN_URL_32}"
    else
        curl -o /tmp/cmake.sh "${CMAKE_BIN_URL_64}"
    fi
    (cd / && echo $'y\nn\n' | bash /tmp/cmake.sh)
    cmake --version
}

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    build_new_zlib
    build_bzip2

    RETURN_PWD="$(pwd)"
    if [ -n "$IS_OSX" ] ; then
        # do not run homebrew cleanup to save time
        export HOMEBREW_NO_INSTALL_CLEANUP="true"
        brew update
        brew install google-sparsehash boost@1.55
    else
        # Linux
        if [ "$MB_ML_VER" == "1" ] ; then
            yum install -y sparsehash-devel
            build_cmake
            build_boost
        fi
        if [ "$MB_ML_VER" == "2010" ] ; then
            # cmake is already present in image
            yum install -y sparsehash-devel expat-devel boost-devel
        fi
    fi

    echo "Using PYTHON_VERSION: ${PYTHON_VERSION}"
    export LIBOSMIUM_PREFIX=${RETURN_PWD}/libosmium
    export PROTOZERO_PREFIX=${RETURN_PWD}/protozero
    export PYBIND11_PREFIX=${RETURN_PWD}/pybind11
    echo "Coming back to ${RETURN_PWD}"
    cd "${RETURN_PWD}"

    export CXX_FLAGS="-D__STDC_FORMAT_MACROS=1"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    # geos needed for shapely tests (for Linux/python versions with no binary wheels)
    # install shapely once libgeos is installed
    if [ ! -n "$IS_OSX" ] ; then
        # because tests are run  in  matthewbrett/trusty:32 or  matthewbrett/trusty:64 image (debian based), use apt to install libraries for shapely
        # try to use binary wheel or install libgeos - or do not run tests at all
        pip install --only-binary :all: shapely || (apt update && apt install -y libgeos-dev && pip install shapely) ||  exit 0
    else
        pip install shapely
    fi
    python --version
    cd ../pyosmium/test
    # Remove build artifacts so they will not interfere with tests
    rm -rf ../build
    python -m nose
}
