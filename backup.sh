#!/bin/bash
# Usage: TODO
set -e

### lifecycle helper functions
prepare_run() {
	backup_root_dir=$1
	conf_file=$2
	if [ ! -d "${backup_root_dir}" ]; then
		mkdir ${backup_root_dir}
		echo "Created backup root directory $1"
	fi
	if [ ! -f "$conf_file" ]; then
		echo "Configuration $conf_file not found, exiting."
		exit 1
	fi
}
setup_ssh_agent() {
	pubkey_list_file=$1
	if [ -f "${pubkey_list_file}" ]; then
	    echo "Setup ssh-agent"
	    eval `ssh-agent -s`
		while IFS='|' read -r pubkey_path; do
		    echo "Adding ssh key ${pubkey_path}"
            ssh-add ${pubkey_path}
        done <"${pubkey_list_file}"
	fi
}
teardown_ssh_agent() {
    pubkey_list_file=$1
	if [ -f "${pubkey_list_file}" ]; then
	    echo "Teardown ssh-agent"
	    ssh-agent -k
	fi
}
iterate_backups() {
	backup_root_dir=$1
	conf_file=$2
	while IFS='|' read -r mirror_dir repo_url; do
		perform_mirror "${backup_root_dir}/${mirror_dir}" ${repo_url}
	done <"${conf_file}"
}
perform_mirror() {
	base_dir="$(pwd)"
	mirror_dir=$1
	repo_url=$2
	if [ -d ${mirror_dir} ]; then
		echo "Update mirror $mirror_dir"
		cd ${mirror_dir}
		git remote update --prune
		cd ${base_dir}
	else
		echo "Initial mirror into $mirror_dir"
		git clone --mirror ${repo_url} ${mirror_dir}
	fi 
}

### global config
base_dir=$(dirname "$0")
conf_file="${base_dir}/conf.txt"
sshkeys_file="${base_dir}/sshkeys.list"
backup_root_dir="${base_dir}/backup"

### main procedural block
prepare_run ${backup_root_dir} ${conf_file}
setup_ssh_agent ${sshkeys_file}
iterate_backups ${backup_root_dir} ${conf_file}
teardown_ssh_agent ${sshkeys_file}
