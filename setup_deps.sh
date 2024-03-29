#!/bin/bash

docom() {
  local COM="$*"
  echo
  echo $COM
  $COM
  return $?
}

gitclone() {
  local PKG=$1
  if [ ! -r $PKG ]; then
    GITURL=https://github.com/dladams/$PKG.git
    if [ $USER = dladams ]; then
      GITURL=git@github.com:dladams/$PKG.git
    fi
    docom git clone $GITURL $2
  fi
}

dune_version() {
  if [ -z "$1" -o "$1" = - -o "$1" = . ]; then
    echo v09_64_00d00
  else
    echo $1
  fi
}

build_deps() {

  local THISDIR=$(pwd)
  local DUNE_VERSION=${1:-v09_61_00d00}
  local BASDIR=$(pwd)/deps
  local PKGDIR=$BASDIR/pkgs
  local RUNDIR=$(pwd)
  local INSDIR=$BASDIR/install/$DUNE_VERSION
  export DUNE_INSTALL_BASE=$INSDIR
  export DUNE_BUILD_BASE=$BASDIR/build/$DUNE_VERSION

  if [ $1 = clean ]; then
    echo "===== Cleaning ====="
    rm -rf $BASDIR
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
  echo "===== Building dunerun ====="
  docom "cd $PKGDIR"
  ls -ls
  if [ ! -r $INSDIR/dunerun ]; then
    docom "dunerun/build -v $DUNE_VERSION"
  fi

  echo
  echo "===== Building duneproc ====="
  source $DUNE_INSTALL_BASE/dunerun/setup.sh
  if [ ! -r $INSDIR/dunebuild ]; then
    docom "dune-run -e dunebuild duneproc/build"
  fi

  cd $THISDIR
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
