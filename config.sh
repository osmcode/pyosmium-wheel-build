#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    # this is run twice

    if [ -n "$IS_OSX" ] ; then
        brew update
        USE_PYTHON_VERSION=${$PYTHON_VERSION:0:1}
        if [ ${USE_PYTHON_VERSION} -eq 2 ] ; then
            PYTHON_SUFFIX=
        else
            PYTHON_SUFFIX=3
        fi
        brew outdated python@${USE_PYTHON_VERSION} || brew upgrade python@${USE_PYTHON_VERSION}
        brew install google-sparsehash
        brew install boost-python${PYTHON_SUFFIX}
    else
        yum install -y sparsehash-devel bzip2-devel zlib-devel
        mkdir -p boost
        RETURN_PWD="$(pwd)"
        cd boost
        export BOOST_PREFIX="$(pwd)"
        # curl -L https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_67_0.tar.bz2 | tar xfj
        curl -L https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.bz2 | tar xfj -
        cd boost_1_66_0/
        BOOST_ROOT="$(pwd)"
        cd tools/build
        sh bootstrap.sh
        ./b2 install --prefix="${BOOST_PREFIX}"
        cd "${BOOST_ROOT}"
        cat << EOF > tools/build/src/site-config.jam
            using gcc ;
            using python : : $(cpython_path "${PYTHON_VERSION}" "${UNICODE_WIDTH}")/bin/python  ;
EOF
        echo "Using following BOOST configuration:"
        cat tools/build/src/site-config.jam

        echo "Using PYTHON_VERSION: ${PYTHON_VERSION}"
        "${BOOST_PREFIX}"/bin/b2 --with-python --toolset=gcc --prefix="${BOOST_PREFIX}" stage install

        # Add boost path to loader and linker
        export LD_LIBRARY_PATH="${BOOST_PREFIX}/lib:${LD_LIBRARY_PATH}"
        export LIBRARY_PATH="${BOOST_PREFIX}/lib"

        echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
        ls ${BOOST_PREFIX}/lib
        echo "End of BOOST libraries list"
        # update ldconfig cache, so find_library will find it
        ldconfig ${BOOST_PREFIX}/lib
    fi

    export LIBOSMIUM_PREFIX=/io/libosmium
    export PROTOZERO_PREFIX=/io/protozero
    echo "Coming back to ${RETURN_PWD}"
    cd "${RETURN_PWD}"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python /io/pyosmium/tests/run_tests.py - empty directory - no tests here...
    cd /
    python -c "import osmium"
}