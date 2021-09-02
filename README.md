# easy gitlab lab with docker on ubuntu

This lab is for docker under ubuntu linux >= 20.04 !

## TL;DR


```bash
git clone https://github.com/david-guenault/docker-gitlab-lab.git
cd docker-gitlab-lab
#first you have to configure your environment variables by **copying env.sh.sample to env.sh** and modify the values in this file so it match your needs. 
sudo ./prerequisites
make prepare
make create
```

## Usage

### install prerequisites

``` bash
cd gitlab
sudo ./prerequisites
```

### prepare

- execute the command *make prepare* to install docker-compose in a virtual environment

### deploy gitlab

```bash
make create
# wait until gitlab is available. This could take some time
make show_root_password
# you can now login to gitlab with root/[the password displayed after the last command]
```

### destroy the stack 
Note: this will remove the gitlab container and all data but not the backup data

```bash
make destroy
```

### destroy and clean 

Note: this will destroy everything and let your environment in the same state as before you deploy. 

```bash
sudo make clean
```

### backup and restore your data

``` bash 
# make a backup
make backup 

# destroy and recreate your existing gitlab
sudo make destroy 
make create

# WAIT UNTIL GITLAB IS AVAILABLE !!!!
# you can check by going into the container and issue the status command
make shell
gitlab-ctl status

run: alertmanager: (pid 1673) 90s; run: log: (pid 1101) 323s
run: gitaly: (pid 1657) 93s; run: log: (pid 541) 720s
run: gitlab-exporter: (pid 1626) 96s; run: log: (pid 1024) 352s
run: gitlab-workhorse: (pid 1607) 97s; run: log: (pid 959) 370s
run: grafana: (pid 1691) 89s; run: log: (pid 1403) 200s
run: logrotate: (pid 473) 739s; run: log: (pid 484) 736s
run: nginx: (pid 991) 367s; run: log: (pid 1009) 363s
run: postgres-exporter: (pid 1683) 89s; run: log: (pid 1123) 314s
run: postgresql: (pid 655) 710s; run: log: (pid 666) 709s
run: prometheus: (pid 1638) 95s; run: log: (pid 1070) 334s
run: puma: (pid 895) 389s; run: log: (pid 905) 386s
run: redis: (pid 490) 734s; run: log: (pid 499) 731s
run: redis-exporter: (pid 1628) 97s; run: log: (pid 1047) 343s
run: sidekiq: (pid 911) 382s; run: log: (pid 924) 379s
run: sshd: (pid 39) 785s; run: log: (pid 38) 785s

# list your backups
sudo make list_backups
Backups
1630258510_2021_08_29_14.1.3

Secret Backups
gitlab_config_1630258514_2021_08_29.tar

# chose your backup and backup secret and perform a restore (it is a long process)
# a restore is always on the same gitlab version ! check before doing a restore
sudo make restore_backup GITLAB_BACKUP=1630258510_2021_08_29_14.1.3 GITLAB_SECRET_BACKUP=gitlab_config_1630258514_2021_08_29.tar

```
### purge backups

you can adjust your backup retention (in days) in env.sh with the environment variable **GITLAB_BACKUP_KEEP**

``` bash
sudo make purge_backups
```