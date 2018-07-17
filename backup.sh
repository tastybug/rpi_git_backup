#!/bin/sh
set -e
# Usage: TODO

# configuration file
conf_file="./conf.txt"

# backup target folder
backup_dir="./backup"

prepare_backup_dir()
{
	if [ ! -d "$1" ]; then
		mkdir $1
		echo "Created backup target directory $1"
	fi
}

read_conf() {
	if [ ! -f "$1" ]; then
		echo "Configuration $1 not found, exiting."
		exit 1
	fi
}

prepare_backup_dir $backup_dir
read_conf conf_file

