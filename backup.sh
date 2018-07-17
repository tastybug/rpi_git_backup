#!/bin/sh
# Usage: TODO

set -e

conf_file="./conf.txt"
backup_root_dir="./backup"
base_dir="$(pwd)"

prepare_run() {
	base_dir=$1
	conf_file=$2
	if [ ! -d "$base_dir" ]; then
		mkdir $base_dir
		echo "Created backup root directory $1"
	fi
	if [ ! -f "$conf_file" ]; then
		echo "Configuration $conf_file not found, exiting."
		exit 1
	fi
}
iterate_backups() {
	backup_root_dir=$1
	conf_file=$2
	while IFS='|' read -r mirror_dir repo_url; do
		perform_mirror "$backup_root_dir/$mirror_dir" $repo_url
	done <"$conf_file"
}
perform_mirror() {
	base_dir="$(pwd)"
	mirror_dir=$1
	repo_url=$2
	if [ -d $mirror_dir ]; then
		echo "Update mirror $mirror_dir"
		cd $mirror_dir
		git remote update --prune
		cd $base_dir
	else
		echo "Initial mirror into $mirror_dir"
		git clone --mirror $repo_url $mirror_dir
	fi 
}
prepare_run $backup_root_dir $conf_file
iterate_backups $backup_root_dir $conf_file
