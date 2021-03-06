# easy pki lab

This lab is for docker under ubuntu linux >= 20.04 !

## prerequisites

You will need the following packages

- python3
- Make
- jq

``` bash
sudo apt -y install jq python3 make
```

## TL;DR

```bash
git clone https://github.com/david-guenault/docker-gitlab-lab.git
cd docker-gitlab-lab/step-ca
#first you have to configure your environment variables by **copying env.sh.sample to env.sh** and modify the values in this file so it match your needs. 
make venv
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

### issue certificate with a validity of more than 24 ours

You will need to customize your env.sh file

modify the **env.sh** file and set 
 - **STEP_CA_CERTIFICATE_DURATION** value to the desired duration 
 - **STEP_CA_MAX_CERTIFICATE_DURATION** for the maximum duration

Note: **maxTLSCertDuration** must be greater than the desired duration.

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
