#!/usr/bin/make

PYTHON=/usr/bin/python3
DOCKER=/usr/bin/docker
BASE:=$(shell cat env.sh | grep GITLAB_HOME= | awk -F= '{print $$2}')
COMPOSE:=$(shell realpath $(BASE)/venv/bin/docker-compose) --env-file ./env.sh 
CONTAINER:=$(shell cat env.sh | grep CONTAINER | awk -F= '{print $$2}')
HOSTNAME:=$(shell cat env.sh | grep 'GITLAB_HOSTNAME=' | grep -v '\#' | awk -F= '{print $$2}')

venv: rmvenv
	$(PYTHON) -m venv venv
	./venv/bin/pip install --upgrade pip wheel
	./venv/bin/pip install docker-compose	

variables:
	@-echo $(PYTHON)
	@-echo $(DOCKER)
	@-echo $(BASE)
	@-echo $(COMPOSE)
	@-echo $(CONTAINER)
	@-echo $(HOSTNAME)

create:
	export GITLAB_HOME=$(BASE) && \
	$(COMPOSE) up -d && \
	mkdir -p secret_backups && \
	$(DOCKER) exec -t $(CONTAINER) mkdir -p /secret/gitlab/backups

update_certificate:
	cd ../step-ca && \
	make tls-cert-renew FQDN=$(HOSTNAME) && \
	make sync && \
	make backup
	make stop
	make start

################################################################
########################    CONTROL    #########################
################################################################	

start:
	@-$(COMPOSE) start

stop:
	@-$(COMPOSE) stop

kill:
	$(COMPOSE) kill

ps:
	@-$(COMPOSE) ps

logs:
	@-$(COMPOSE) logs -f

status:
	$(DOCKER) exec $(CONTAINER) bash -l -c "/opt/gitlab/bin/gitlab-ctl status"

################################################################
########################   UTILITIES   #########################
################################################################

display_uri:
	IGNORE := $(shell bash -c "source env.sh; env | sed 's/=/:=/' | sed 's/^/export /' > makeenv")
	include makeenv 
	echo $(GITLAB_URI)

reconfigure:
	$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl reconfigure

shell:
	$(DOCKER) exec -ti $(CONTAINER) /bin/bash

show_root_password:
	$(DOCKER) exec -ti $(CONTAINER) cat /etc/gitlab/initial_root_password | grep "Password:"



################################################################
######################## GITLAB REMOVE #########################
################################################################

rm:
	@-$(COMPOSE) rm -f

remove_orphaned_volumes:
	@-$(DOCKER) volume rm $$(docker volume ls -qf dangling=true)

rmvolumes:
	@-$(COMPOSE) rm -v -f

rmdata:
	sudo rm -Rf config data logs

rmvenv:
	sudo rm -Rf venv

destroy: kill rmdata rmvolumes

clean: destroy rmbackup rmvenv

################################################################
######################## GITLAB BACKUPS ########################
################################################################

backup:
	$(DOCKER) exec -ti $(CONTAINER) gitlab-backup
	$(DOCKER) exec -ti $(CONTAINER) /bin/sh -c 'gitlab-ctl backup-etc && cd /etc/gitlab/config_backup/ && cp $$(ls -1 /etc/gitlab/config_backup/ | sort -n | tail -n 1) /secret/gitlab/backups/'

list_backups:
	@-echo "Backups"
	@-ls -1 backups | grep "gitlab_backup\.tar" | sed -e "s/_gitlab_backup\.tar//g"
	@-echo ""
	@-echo "Secret Backups"
	@-ls -1 secret_backups | grep -i gitlab_config

restore_backup:
	@-echo "RESTORE DATA"
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl stop puma
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl stop sidekiq
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-backup restore BACKUP=$(GITLAB_BACKUP) force=yes
	@ echo "RESTORE SECRETS"
	@-cd secret_backups && \
	tar xvf $(GITLAB_SECRET_BACKUP) && \
	cp -a etc/* ../config/
	@-echo "RESTART AND CHECK"
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl reconfigure
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl restart
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-rake gitlab:check SANITIZE=true
	@-$(DOCKER) exec -ti $(CONTAINER) gitlab-rake gitlab:doctor:secrets
	
purge_backups:
	@-./purge_backups.sh

rmbackup:
	rm -Rf backups secret_backups

################################################################
######################## GITLAB RUNNERS ########################
################################################################

clean_runners: unregister_runners remove_runners clean_runners_config

install_runners: create_runners register_runners

register_runners:
	@-./register_runners.sh

create_runners:
	@-./create_runners.sh

remove_runners:
	@-./remove_runners.sh

unregister_runners:
	@-./unregister_runners.sh

clean_runners_config:
	@-sudo rm -Rf ./runners

.PHONY: backup destroy list_backups purge_backups rm rmvenv show_root_password stop clean gitlab_status logs reconfigure rmbackup rmvolumes start venv create kill ps restore_backup rmdata shell status 