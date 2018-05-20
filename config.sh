#!/usr/bin/env bash

# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.


    if [ -n "$IS_OSX" ] ; then
        brew update
        brew install google-sparsehash || true
    else
        yum install -y sparsehash-devel bzip2-devel zlib-devel
    fi
    mkdir -p boost
    RETURN_PWD="$(pwd)"
    cd boost
    export BOOST_PREFIX="$(pwd)"
    curl -L https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.bz2 | tar xfj -
    cd boost_1_66_0/
    BOOST_ROOT="$(pwd)"
    cd tools/build
    sh bootstrap.sh
    ./b2 install --prefix="${BOOST_PREFIX}"
    cd "${BOOST_ROOT}"

    if [ -n "$IS_OSX" ] ; then
        cat << EOF > tools/build/src/site-config.jam
                using clang ;
                using python : : ${PYTHON_EXE} : $(${PYTHON_EXE} -c 'from sysconfig import get_paths; print(get_paths()["include"])') ;
EOF
        echo "Python includes: "
        ls -d $(${PYTHON_EXE} -c 'from sysconfig import get_paths; print(get_paths()["include"])')
        ls $(${PYTHON_EXE} -c 'from sysconfig import get_paths; print(get_paths()["include"])')
    else
        cat << EOF > tools/build/src/site-config.jam
                using gcc ;
                using python : : $(cpython_path "${PYTHON_VERSION}" "${UNICODE_WIDTH}")/bin/python : $(echo $(cpython_path "${PYTHON_VERSION}" "${UNICODE_WIDTH}")/include/*) ;
EOF
    fi

    echo "Using following BOOST configuration:"
    cat tools/build/src/site-config.jam

    echo "Using PYTHON_VERSION: ${PYTHON_VERSION}"
    "${BOOST_PREFIX}"/bin/b2 --with-python --prefix="${BOOST_PREFIX}" stage install

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

    cd "${RETURN_PWD}"
    export LIBOSMIUM_PREFIX=${RETURN_PWD}/libosmium
    export PROTOZERO_PREFIX=${RETURN_PWD}/protozero
    echo "Coming back to ${RETURN_PWD}"

}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python /io/pyosmium/tests/run_tests.py - empty directory - no tests here...
    cd /
    python -c "import osmium"
}
