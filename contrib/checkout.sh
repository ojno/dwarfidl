#!/bin/bash

# What I'm going to assume you have:
# 
# bash + other GNU basics
# mercurial + Hg-git
# g++ 4.8 or later
# boost 1.52 or later
# libdwarf (a recent version)
# libelf1

MAKE=${MAKE:-make}

gen_makefile () {
    for basepath in "$@"; do
        echo "CXXFLAGS += -I${basepath}/include"
    done
    for basepath in "$@"; do
        echo "LDFLAGS += -L${basepath}/lib -Wl,-R${basepath}/lib"
    done
    echo "include Makefile"
}

checkout () {
    hg clone git+https://github.com/stephenrkell/$1.git $1 || \
    git clone https://github.com/stephenrkell/$1.git $1
}

([ -d libcxxfileno ] || checkout libcxxfileno) && ${MAKE} -C libcxxfileno && \
([ -d libsrk31cxx  ] || checkout libsrk31cxx) && gen_makefile "$( readlink -f libcxxfileno )" > libsrk31cxx/src/makefile && ${MAKE} -C libsrk31cxx && \
([ -d libdwarfpp ] || checkout libdwarfpp) && \
  gen_makefile "$( readlink -f libcxxfileno )" "$( readlink -f libsrk31cxx )"> libdwarfpp/src/makefile && \
  gen_makefile "$( readlink -f libcxxfileno )" "$( readlink -f libsrk31cxx )"> libdwarfpp/examples/makefile && \
   ${MAKE} -C libdwarfpp && \
([ -d libcxxgen ] || checkout libcxxgen) && gen_makefile "$( readlink -f libcxxfileno )" "$( readlink -f libsrk31cxx )" "$( readlink -f libdwarfpp )"> libcxxgen/src/makefile && ${MAKE} -C libcxxgen && \
gen_makefile "$( readlink -f libcxxfileno )" "$( readlink -f libsrk31cxx )" "$( readlink -f libdwarfpp )" "$( readlink -f libcxxgen )" \
> $(dirname $0)/../src/makefile
