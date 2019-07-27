#!/bin/bash
# Usage: Call script directly from anywhere, no arguments expected.
set -e

### lifecycle helper functions
prepare_run() {
	backup_root_dir=$1
	repo_list_file=$2
	if [ ! -d "${backup_root_dir}" ]; then
		mkdir ${backup_root_dir}
		echo "Created backup root directory ${backup_root_dir}"
	fi
	if [ ! -f "${repo_list_file}" ]; then
		echo "Repository list file ${repo_list_file} not found, exiting."
		exit 1
	fi
}
setup_ssh_agent() {
	sshkey_list_file=$1
	if [ -f "${sshkey_list_file}" ]; then
	    	echo "Setup ssh-agent"
	    	eval `ssh-agent -s`
		while IFS='|' read -r sshkey_path; do
		    	echo "Adding ssh key ${sshkey_path}"
            		ssh-add ${sshkey_path}
		done <"${sshkey_list_file}"
	fi
}
teardown_ssh_agent() {
    sshkey_list_file=$1
	if [ -f "${sshkey_list_file}" ]; then
	    echo "Teardown ssh-agent"
	    ssh-agent -k
	fi
}
iterate_backups() {
	backup_root_dir=$1
	repo_list_file=$2
	while IFS='|' read -r mirror_dir repo_url; do
		perform_mirror ${backup_root_dir} "${backup_root_dir}/${mirror_dir}" ${repo_url}
	done <"${repo_list_file}"
}
perform_mirror() {
	backup_root_dir=$1
	mirror_dir=$2
	repo_url=$3
	if [ -d ${mirror_dir} ]; then
		echo "Update mirror $mirror_dir"
		cd ${mirror_dir}
		git remote update --prune
		cd ../..
	else
		echo "Initial mirror into $mirror_dir"
		git clone --mirror ${repo_url} ${mirror_dir}
	fi 
}

### global config
base_dir=$(dirname "$0")
repo_list_file="${base_dir}/repos.list"
sshkey_list_file="${base_dir}/sshkeys.list"
backup_root_dir="${base_dir}/backup"

### main procedural block
prepare_run ${backup_root_dir} ${repo_list_file}
setup_ssh_agent ${sshkey_list_file}
iterate_backups ${backup_root_dir} ${repo_list_file}
teardown_ssh_agent ${sshkey_list_file}
