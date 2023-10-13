#!/bin/sh

if [ "$(uname -m)" == "aarch64" ]
then
    yum install -y wget
    wget https://download-ib01.fedoraproject.org/pub/epel/7/aarch64/Packages/g/geos-3.4.2-2.el7.aarch64.rpm
    rpm -i geos-3.4.2-2.el7.aarch64.rpm
    rm geos-3.4.2-2.el7.aarch64.rpm
fi
