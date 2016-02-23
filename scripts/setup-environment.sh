#!/bin/sh
##############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the Boot to Qt meta layer.
##
## $QT_BEGIN_LICENSE:COMM$
##
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## $QT_END_LICENSE$
##
##############################################################################

while test -n "$1"; do
  case "$1" in
    "--help" | "-h")
      echo "Usage: . $0 [build directory]"
      return 0
      ;;
    *)
      BUILDDIRECTORY=$1
    ;;
  esac
  shift
done

THIS_SCRIPT="setup-environment.sh"
if [ "$(basename $0)" = "${THIS_SCRIPT}" ]; then
    echo "Error: This script needs to be sourced. Please run as '. $0'"
    exit 1
fi

if [ -z "$MACHINE" ]; then
  echo "Error: MACHINE environment variable not defined"
  return 1
fi

BUILDDIRECTORY=${BUILDDIRECTORY:-build-${MACHINE}}

if [ ! -f ${PWD}/${BUILDDIRECTORY}/conf/bblayers.conf ]; then
  case ${MACHINE} in
    apalis-imx6|colibri-imx6|colibri-vf)
      LAYERSCONF="bblayers.conf.toradex.sample"
    ;;
    imx53qsb|imx6qsabresd|imx6dlsabresd|nitrogen6x)
      LAYERSCONF="bblayers.conf.fsl.sample"
    ;;
    smarc-samx6i)
      LAYERSCONF="bblayers.conf.smx6.sample"
    ;;
    tibidabo)
      LAYERSCONF="bblayers.conf.tibidabo.sample"
    ;;
    beagleboard|am335x-evm)
      LAYERSCONF="bblayers.conf.ti.sample"
    ;;
    beaglebone)
      LAYERSCONF="bblayers.conf.bbb.sample"
    ;;
    raspberrypi|raspberrypi2)
      LAYERSCONF="bblayers.conf.rpi.sample"
    ;;
    nuc)
      LAYERSCONF="bblayers.conf.nuc.sample"
    ;;
    nvidia-logan)
      LAYERSCONF="bblayers.conf.nvidia-logan.sample"
    ;;
    emulator)
      LAYERSCONF="bblayers.conf.emulator.sample"
    ;;
    *)
      LAYERSCONF="bblayers.conf.sample"
      echo "Unknown MACHINE, bblayers.conf might need manual editing"
    ;;
  esac

  mkdir -p ${PWD}/${BUILDDIRECTORY}/conf
  cp ${PWD}/sources/meta-b2qt/conf/${LAYERSCONF} ${PWD}/${BUILDDIRECTORY}/conf/bblayers.conf

  if [ ! -d ${PWD}/sources/meta-qt5 ]; then
    sed -i -e '/meta-qt5/d' ${PWD}/${BUILDDIRECTORY}/conf/bblayers.conf
  fi

  if [ ! -d ${PWD}/sources/meta-b2qt/.git ]; then
    QT_SDK_PATH=$(readlink -f ${PWD}/sources/meta-b2qt/../../../../)
  fi
fi

export TEMPLATECONF="${PWD}/sources/meta-b2qt/conf"
. sources/poky/oe-init-build-env ${BUILDDIRECTORY}

# use sources from Qt SDK if that is available
sed -i -e "/QT_SDK_PATH/s:\"\":\"${QT_SDK_PATH}\":" conf/local.conf

unset BUILDDIRECTORY
unset QT_SDK_PATH
unset TEMPLATECONF
unset LAYERSCONF
