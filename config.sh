#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    build_new_zlib
    build_bzip2

    RETURN_PWD="$(pwd)"
    if [ -n "$IS_OSX" ] ; then
        brew update
        brew install google-sparsehash || true
    else
        yum install -y sparsehash-devel expat-devel
    fi

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
    "${BOOST_PREFIX}"/bin/b2 --without-python --prefix="${BOOST_PREFIX}" install > /dev/null

    ####
    # END of BOOST stuff
    ####

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
    python --version
    # python /io/pyosmium/tests/run_tests.py - empty directory - no tests here...
    cd /
    python -c "import osmium"
}
