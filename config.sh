#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    # this is run twice

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
    ./b2 install --prefix="$(BOOST_PREFIX)"
    cd "${BOOST_ROOT}"
    cat << EOF > tools/build/src/site-config.jam
using gcc ;
using python : : $(cpython_path $PYTHON_VERSION $UNICODE_WIDTH) ;
EOF

#using python : 2.7u : /opt/python/cp27-cp27mu ;
#using python : 3.4 : /opt/python/cp34-cp34m ;
#using python : 3.5 : /opt/python/cp35-cp35m ;
#using python : 3.6 : /opt/python/cp36-cp36m ;
    echo "Using follwing BOOST configuration:"
    cat tools/build/src/site-config.jam

    b2 --with-python --toolset=gcc --prefix="$(BOOST_PREFIX)" stage install
    # cd stage/lib tar cf - . | ( cd /usr/local/lib64 && tar xf - )



 #   if [ -e /usr/lib64/libboost_python.so.1.48.0  ] && [ ! -e /usr/lib64/libboost_python.so  ] ; then
 #       ln -sf /usr/lib64/libboost_python.so.1.48.0 /usr/lib64/libboost_python.so
 #   fi

#    if [ -e /usr/lib/libboost_python.so.1.48.0 ] && [ ! -e /usr/lib/libboost_python.so ] ; then
#        ln -s /usr/lib/libboost_python.so.1.48.0 /usr/lib/libboost_python.so
#    fi

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