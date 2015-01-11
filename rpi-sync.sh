#!/bin/bash

# user name and host name or IP of the RPi in SSH syntax
readonly USER_HOST="pi@raspberrypi.home"
# path on the local machine where the backups should go
readonly DEST_DIR="/data/"
# file containing folders excluded from synchronization on the RPi
readonly EXCLUDE_FILE="rpi-excludes.txt"

readonly DATE_STR=$(date -u +%Y-%m-%d--%H-%M)

rpi_sync() {
	# rsync boot partition from
	rsync -axv --del -e "ssh" --rsync-path="sudo rsync" "${USER_HOST}:/boot/" "${DEST_DIR}/rpi-boot-${DATE_STR}/"
	# copy latest root partition backup locally using rsync, so we do not have to
	# rsync everything from the RPi, if we already have synchronized to rpi-root
	if [ -d "${DEST_DIR}/rpi-root/" ]; then
		rsync -axv --del "${DEST_DIR}/rpi-root/" "${DEST_DIR}/rpi-root-${DATE_STR}/"
	fi
	# rsync RPi root partition into local copy
	rsync -axv --del --exclude-from="${EXCLUDE_FILE}" -e "ssh" --rsync-path="sudo rsync" "${USER_HOST}:/" "${DEST_DIR}/rpi-root-${DATE_STR}/"
	# link to new local copy of root partition
	rm "${DEST_DIR}/rpi-root" && ln -s "${DEST_DIR}/rpi-root-${DATE_STR}/" "${DEST_DIR}/rpi-root"
}

main() {
	if [ $EUID -eq 0 ]; then
		echo "Do not run this script as root"
		exit 1
	else
		rpi_sync
	fi
}

main

