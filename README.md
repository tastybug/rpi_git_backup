## RPI as automated git backup

Got an old Raspberry collecting dust, maybe even one of those Raspberry 1B models from 2013? Why not use it as a cheap
backup server for your various git repositories?

### Setup

1) Prepare your RPI:
Make sure you have a Raspberry PI with sufficient space on its SD card or attached hard disc, depending on size and amount of repositories that are to be monitored. Make also sure that `openssh`, `git` and `cron` are installed.

1) Download this repo:
Clone this repository into your RPI using a OS user that will do the mirroring later on. Check `conf.txt`; for each git
repository that you want to mirror, add a line as such: `folder_to_mirror_into|git_repo_url`.

1) Do a manual first run:
The backup is done using a simple script, `backup.sh`. You can run it either via `sh backup.sh` or directly 
`./backup.sh` once you made it executable (`chmod a+x backup.sh`). The script creates a backup root folder `./backup`
and will start to mirror all repositories mentioned in `conf.txt`.

1) Backup automatically:
You'll want to run the mirroring on a regular base, maybe nightly or once a week. TODO details

1) SSH-Keys, TODO

### Limitations

* No http repos
* bad observability / no notification mechanism
