#!/bin/sh

PYTHON_VERSION="3.13"
BASE_URL="http://ftp.us.debian.org/debian/pool/main/p/python${PYTHON_VERSION}"
DEBVERSION="3.13.5-2"

DIST="dist"

mkdir -p ${DIST}/lib/debug/.build-id/
mkdir -p ${DIST}/share/gdb/auto-load/usr/bin/
mkdir -p ${DIST}/share/gdb/auto-load/usr/lib/x86_64-linux-gnu/

mkdir -p build
wget ${BASE_URL}/python${PYTHON_VERSION}-dbg_${DEBVERSION}_amd64.deb
dpkg-deb -x python${PYTHON_VERSION}-dbg_${DEBVERSION}_amd64.deb build/
PYTHON3_BUILDID="$(file -b /usr/bin/python${PYTHON_VERSION} | sed -E 's/^.+, BuildID\[sha1\]=([0-9a-f]{2})([0-9a-f]{38}), .+$/\1\/\2/')"
mkdir -p ${DIST}/lib/debug/.build-id/"$(dirname ${PYTHON3_BUILDID})"/
cp build/usr/lib/debug/.build-id/"${PYTHON3_BUILDID}".debug ${DIST}/lib/debug/.build-id/"$(dirname ${PYTHON3_BUILDID})"/
LIBPYTHON3_FILENAME=$(realpath /usr/lib/x86_64-linux-gnu/libpython${PYTHON_VERSION}.so)
LIBPYTHON3_BUILDID="$(file -b ${LIBPYTHON3_FILENAME} | sed -E 's/^.+, BuildID\[sha1\]=([0-9a-f]{2})([0-9a-f]{38}), .+$/\1\/\2/')"
mkdir -p ${DIST}/lib/debug/.build-id/"$(dirname ${LIBPYTHON3_BUILDID})"/
cp build/usr/lib/debug/.build-id/"${LIBPYTHON3_BUILDID}".debug ${DIST}/lib/debug/.build-id/"$(dirname ${LIBPYTHON3_BUILDID})"/
cp libpython.py ${DIST}/share/gdb/auto-load/usr/bin/python${PYTHON_VERSION}-gdb.py
ln -s ../../bin/python${PYTHON_VERSION}-gdb.py ${DIST}/share/gdb/auto-load${LIBPYTHON3_FILENAME}-gdb.py

rm -rf build
