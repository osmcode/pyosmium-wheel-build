#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

CMAKE_BIN_URL=https://cmake.org/files/v3.6/cmake-3.6.3-Linux-x86_64.sh

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    RETURN_PWD="$(pwd)"
    if [ -n "$IS_OSX" ] ; then
        brew update
        brew install google-sparsehash || true
    else
        yum install -y sparsehash-devel bzip2-devel zlib-devel
    fi

    ####
    # CMake
    ####
    curl -o /tmp/cmake.sh https://cmake.org/files/v3.6/cmake-3.6.3-Linux-x86_64.sh
    (
        cd /
        echo $'y\nn' | bash /tmp/cmake.sh
    )
    cmake --version
    mkdir -p ${RETURN_PWD}/pyosmium/contrib/

    ####
    # End of CMake
    ####

    ####
    # BOOST 
    ####
    mkdir -p boost
    cd boost
    export BOOST_PREFIX="$(pwd)"
    curl -L https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.bz2 | tar xfj -
    cd boost_1_66_0/
    BOOST_ROOT="$(pwd)"
    cd tools/build
    sh bootstrap.sh
    ./b2 --prefix="${BOOST_PREFIX}" --without-python install 
    cd "${BOOST_ROOT}"

    if [ -n "$IS_OSX" ] ; then
        export DYLD_LIBRARY_PATH="${BOOST_PREFIX}/lib:${DYLD_LIBRARY_PATH}"
    else
        # Add boost path to loader and linker
        export LD_LIBRARY_PATH="${BOOST_PREFIX}/lib:${LD_LIBRARY_PATH}"
        export LIBRARY_PATH="${BOOST_PREFIX}/lib"

        echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
        ls ${BOOST_PREFIX}/lib
        echo "End of BOOST libraries list"
        # update ldconfig cache, so find_library will find it
        ldconfig ${BOOST_PREFIX}/lib
    fi


    ####
    # END of BOOST stuff
    ####

    echo "Using PYTHON_VERSION: ${PYTHON_VERSION}"
    export LIBOSMIUM_PREFIX=${RETURN_PWD}/libosmium
    export PROTOZERO_PREFIX=${RETURN_PWD}/protozero
    echo "Coming back to ${RETURN_PWD}"
    cd "${RETURN_PWD}"

    export CXX_FLAGS="-D__STDC_FORMAT_MACROS=1"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python /io/pyosmium/tests/run_tests.py - empty directory - no tests here...
    cd /
    python -c "import osmium"
}
