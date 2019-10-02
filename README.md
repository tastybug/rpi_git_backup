# Automated git mirroring with Raspberry PI

Got an old Raspberry collecting dust, maybe even one of those slow Raspberry 1B models from 2013? Why not use it as a low power backup server for your git repositories?

This works for public and private repositories and any hoster.

## Setup

#### Prepare the RPI
Any type of RPI will do, even the 2013 Raspberry 1B. Make sure to have sufficient local storage space. Any Linux distribution should work, as long as `openssh`, `git` and `cron` are installed.

#### What is to be mirrored?
Figure out which repositories you want mirrored and consider whether its public or private.
1) If its a public repo, have the HTTP clone URL ready.
1) For private repos there needs to be a SSH key available to the script, see below for details. Have the private key and the SSH URL of your repo ready.

#### Setup the mirroring script
Clone this repository into your RPI using a system user that will do the mirroring later on. Create a file named `repos.list`; for each git repository that you want to mirror, add a line as such: `folder_name|git_repo_url`. The first argument will be the folder that the mirrored repository (2nd argument) will be mirrored into: `backup/$folder_name`.

#### Private repositories 
For private repos it's recommended to use the [deploy keys feature on Github](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys) or [access keys on Bitbucket](https://confluence.atlassian.com/bitbucket/access-keys-294486051.html). There needs to be a private SSH key that grants access to the repository that you want mirrored. If you want to run the mirroring script unattended, the key must not be password protected.

Once you have the key setup sorted for all affected repositories, create a file named `sshkeys.list` next to `backup.sh`. In `sshkeys.list` add a line with an absolute path of each SSH private key that will be needed for any of the mirrored private repos:

```
/home/backupuser/.ssh/backup_key
/home/backupuser/.ssh/some_other_backup_key
```

## Run it

#### Manually
The backup is done using `backup.sh`. The script creates directory `./backup` and will start to mirror all repositories mentioned in `repos.list` into this folder.

#### Periodically
You'll want to run the mirroring on a regular base, maybe nightly or once a week. Be considerate and do not run it more often than necessary.
Periodic runs can be achieved with [cron](https://help.ubuntu.com/community/CronHowto). Running it daily at 4 in the morning would look like this:
```
# m h dom mon dow command
0 4 * * * /home/backupuser/rpi_git_mirror/backup.sh >> /home/backupuser/rpi_git_mirror/cron.log
```