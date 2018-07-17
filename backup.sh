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

assert_conf() {
	if [ ! -f "$1" ]; then
		echo "Configuration $1 not found, exiting."
		exit 1
	fi
}
iterate_backups() {
	backup_root=$1
	conf=$2
	while IFS='|' read -r mirror_dir repo_url; do
		perform_mirror "$backup_root/$mirror_dir" $repo_url
	done <"$conf_file"
}
perform_mirror() {
	mirror_dir=$1
	repo_url=$2
	echo "$repo_url to $mirror_dir"
	if [ -d $mirror_dir ]; then
		update_mirror $mirror_dir $repo_url
	else
		initial_clone $mirror_dir $repo_url
	fi 
}
initial_clone() {
	mirror_dir=$1
	repo_url=$2
	echo "init $mirror_dir"
	mkdir $mirror_dir
}
update_mirror() {
	mirror_dir=$1
	repo_url=$2
	echo "update $mirror_dir"
}

prepare_backup_dir $backup_dir
assert_conf $conf_file
iterate_backups $backup_dir $conf_file
