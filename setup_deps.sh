#!/bin/bash

docom() {
  COM="$*"
  echo
  echo $COM
  $COM
  return $?
}

writecom() {
  echo $* >>$OUTFIL
}

gitclone() {
  PKG=$1
  if [ ! -r $PKG ]; then
    GITURL=https://github.com/dladams/$PKG.git
    if [ $USER = dladams ]; then
      GITURL=git@github.com:dladams/$PKG.git
    fi
    docom git clone $GITURL $2
  fi
}

dune_version() {
 echo ${1:-v09_61_00d00}
}

build_deps() {

DUNE_VERSION=${1:-v09_61_00d00}
BASDIR=$(pwd)/deps
PKGDIR=$BASDIR/pkgs
RUNDIR=$(pwd)
INSDIR=$BASDIR/install/$DUNE_VERSION
OUTFIL=$(pwd)/setup_deps
export DUNE_INSTALL_BASE=$INSDIR
export DUNE_BUILD_BASE=/tmp/$USER/vdcoldbox-deps/build/$DUNE_VERSION

if [ $1 = clean ]; then
  echo "===== Cleaning ====="
  rm -rf $BASDIR $OUTFIL
fi

echo
echo "===== Creating directories ====="
for DIR in $PKGDIR; do
  if [ ! -r $DIR ]; then
    docom mkdir -p $DIR
  fi
done

echo
echo "===== Cloning ====="
docom cd $PKGDIR
gitclone dunerun
gitclone duneproc

echo
echo "===== Building ====="
docom "cd $PKGDIR"
ls -ls
if [ ! -r $INSDIR/dunerun ]; then
  docom "dunerun/build -v $DUNE_VERSION"
fi
source $DUNE_INSTALL_BASE/dunerun/setup.sh
if [ ! -r $INSDIR/dunebuild ]; then
  docom "dune-run -e dunebuild duneproc/build"
fi

rm -rf $OUTFIL
writecom source $INSDIR/dunerun/setup.sh
echo Created $OUTFIL
writecom INSDIR=$INSDIR

}

_THISFILE=$(readlink -f $BASH_SOURCE)
_VER=$(dune_version $1)
_BASDIR=$(dirname $_THISFILE)/deps
_INSDIR=$_BASDIR/install/$_VER
_SETFIL=$_INSDIR/dunerun/setup.sh

if [ ! -r $_SETFIL ]; then
  build_deps $_VER
fi

if [ -r $_SETFIL ]; then
  echo Setting up dunerun $_VER
  source $_SETFIL
else
  echo Not found: $_SETFIL
fi
