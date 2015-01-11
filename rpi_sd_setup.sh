#!/bin/bash

readonly IMAGE="RetroPieImage_ver1.8"
readonly SD="/dev/mmcblk0"

rpi_sd_setup() {
  echo "Generating checksum"
  shasum "$IMAGE".zip
  echo "Unzipping file"
  unzip "$IMAGE".zip
  echo "Imaging SD card"
  dd bs=4M if="$IMAGE".img of="$SD"
  sync
}

rpi_sd_setup

