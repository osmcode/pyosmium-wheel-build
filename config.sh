#!/usr/bin/env bash
set -e -x

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    yum install -y boost148-python boost148-devel sparsehash-devel bzip2-devel zlib-devel

    export BOOST_VERSION=148
    export LIBOSMIUM_PREFIX=/io/libosmium
    export PROTOZERO_PREFIX=/io/protozero


    :
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python pyosmium/tests/run_tests.py
    python -c "import osmium"
}