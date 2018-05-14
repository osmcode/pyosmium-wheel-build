#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    # this is run twice

    yum install -y boost148-python boost148-devel sparsehash-devel bzip2-devel zlib-devel

    if [ -e /usr/lib64/libboost_python.so.1.48.0  ] && [ ! -e /usr/lib64/libboost_python.so  ] ; then
        ln -sf /usr/lib64/libboost_python.so.1.48.0 /usr/lib64/libboost_python.so
    fi

    if [ -e /usr/lib/libboost_python.so.1.48.0 ] && [ ! -e /usr/lib/libboost_python.so ] ; then
        ln -s /usr/lib/libboost_python.so.1.48.0 /usr/lib/libboost_python.so
    fi

    export BOOST_VERSION=148
    export LIBOSMIUM_PREFIX=/io/libosmium
    export PROTOZERO_PREFIX=/io/protozero
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python /io/pyosmium/tests/run_tests.py - empty directory - no tests here...
    python -c "import osmium"
}