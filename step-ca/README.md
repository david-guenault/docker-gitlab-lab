# easy pki lab

This lab is for docker under ubuntu linux >= 20.04 !

## TL;DR

Note: you must init your gitlab project first !!!!


```bash
git clone https://github.com/david-guenault/docker-gitlab-lab.git
cd docker-gitlab-lab/step-ca
#first you have to configure your environment variables by **copying env.sh.sample to env.sh** and modify the values in this file so it match your needs. 
make init
make tls-cert FQDN=your.domain.name
make sync
# your certs are in $STEPCA_HOME/step-ca/home/step/
```

## Usage

### deploy step-ca

```bash
make init
```

### destroy the stack 
Note: this will remove the step-ca container and all data but not the backup data

```bash
make destroy
```

### destroy and clean 

Note: this will destroy everything and let your environment in the same state as before you deploy. 

```bash
sudo make clean
```

### create a TLS certificate

```bash
make tls-cert FQDN=your.domain.tld
make sync
# your certs are in step-ca/home/step
```

### backup and restore your data

``` bash 
# make a backup
make backup 

# destroy and recreate your step-ca pki
make destroy 
make init

# WAIT UNTIL step-ca IS AVAILABLE !!!!

# list your backups
sudo make list-backups
step-ca.1630836664.tar.gz
step-ca.1630836680.tar.gz
step-ca.1630836682.tar.gz
# chose your backup and perform a restore 
make restore-backup BACKUP=step-ca.1630836680.tar.gz
make sync
```

### purge backups

TBD