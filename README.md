## Automated git mirroring with Raspberry PI

Got an old Raspberry collecting dust, maybe even one of those slow Raspberry 1B models from 2013? Why not use it as a 
cheap backup server for your various git repositories?

This works for public and private repositories and any hoster, be it github, bitbucket or others.

## Setup

#### Prepare the RPI
Make sure you have a Raspberry PI with sufficient space. Pretty much any type of RPI should do, even the older ones 
(this continuously runs on a 2013 Raspberry 1B). No specific Linux distribution is necessary, but the packages 
`openssh`, `git` and `cron` are expected to be installed.

#### What is to be mirrored?
Figure out which repositories you want mirrored and consider whether its public or private.
1) If its a public repo, copy the http clone URL.
1) For private repos there needs to be a ssh key available to the script, see below for details. Have the key and 
the ssh URL of your repo ready.

#### Setup the mirroring script
Clone this repository into your RPI using a system user that will do the mirroring later on. Create a file named 
`conf.txt`; for each git repository that you want to mirror, add a line as such: `folder_name|git_repo_url`. The first
argument will be the folder that the mirrored repository (2nd argument) will be mirrored into: `./backup/$FOLDER_NAME`.

#### Got private repos? 
For private repos it's recommended to use the [deploy keys feature on Github](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys)
or [access keys on Bitbucket](https://confluence.atlassian.com/bitbucket/access-keys-294486051.html) or something similar.
Essentially there needs to be a private ssh key that grants access to the repository that you want mirrored. If you
want to run the mirroring script unattended, the key must not be password protected.

Once you have the key setup sorted for all affected repositories, create a file named `sshkeys.list`  next to 
`backup.sh`. In `sshkeys.list` add a line with an absolute path of each ssh private key that will be needed for any of 
the mirrored private repos, e.g. 

```
/home/backupuser/.ssh/backup_key
/home/backupuser/.ssh/some_other_backup_key
```

## Run it

#### Manually
The backup is done using a simple script, `backup.sh`. You can run it either via `bash backup.sh` or directly 
`./backup.sh` once you made it executable (`chmod a+x backup.sh`). The script creates a backup root folder `./backup`
and will start to mirror all repositories mentioned in `conf.txt`.

#### Periodically
You'll want to run the mirroring on a regular base, maybe nightly or once a week. Be nice and do not run it more often
than necessary.
Periodic runs can be achieved with [cron](https://help.ubuntu.com/community/CronHowto). Running it daily at 4 in the
morning would look like this:
```
# m h dom mon dow command
0 4 * * * cd /home/backupuser/rpi_git_mirror && /home/backupuser/rpi_git_mirror/backup.sh
```

## Limitations

* bad observability / no notification mechanism
* current working directory for backup script is assumed to be `.`
