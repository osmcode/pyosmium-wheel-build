#!/bin/sh
set -ex
set -o functrace

echo "Running macOS steps"

if [ -f cibuild_steps_done ] ; then
    exit 0
fi

export PLAT=x86_64

. $(pwd)/multibuild/manylinux_utils.sh
. $(pwd)/multibuild/library_builders.sh

mkdir pyosmium/contrib

ln -sf $(pwd)/pybind11 pyosmium/contrib/pybind11
ln -sf $(pwd)/libosmium pyosmium/contrib/libosmium
ln -sf $(pwd)/protozero pyosmium/contrib/protozero


build_new_zlib
build_bzip2
export HOMEBREW_NO_INSTALL_CLEANUP="true"
brew update
brew install google-sparsehash boost

touch cibuild_steps_done
