#!/usr/bin/make

PYTHON=/usr/bin/python3
DOCKER=/usr/bin/docker
BASE:=$(shell cat env.sh | grep GITLAB_HOME= | awk -F= '{print $$2}')
COMPOSE:=$(shell realpath $$(BASE)/venv/bin/docker-compose) --env-file ./env.sh 
CONTAINER:=$(shell cat env.sh | grep CONTAINER | awk -F= '{print $$2}')

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

create:
	export GITLAB_HOME=$(BASE) && \
	$(COMPOSE) up -d && \
	mkdir -p secret_backups && \
	$(DOCKER) exec -t $(CONTAINER) mkdir -p /secret/gitlab/backups

kill:
	$(COMPOSE) kill

rm:
	@-$(COMPOSE) rm -f

logs:
	@-$(COMPOSE) logs -f

stop:
	@-$(COMPOSE) stop

ps:
	@-$(COMPOSE) ps

start:
	@-$(COMPOSE) start

gitlab_status:
	$(COMPOSE) exec -ti $(CONTAINER) "sudo gitlab-ctl --help"

reconfigure:
	$(DOCKER) exec -ti $(CONTAINER) gitlab-ctl reconfigure

shell:
	$(DOCKER) exec -ti $(CONTAINER) /bin/bash

show_root_password:
	$(DOCKER) exec -ti $(CONTAINER) cat /etc/gitlab/initial_root_password | grep "Password:"

backup:
	$(DOCKER) exec -ti $(CONTAINER) gitlab-backup
	$(DOCKER) exec -ti $(CONTAINER) /bin/sh -c 'gitlab-ctl backup-etc && cd /etc/gitlab/config_backup/ && cp $$(ls -1 /etc/gitlab/config_backup/ | sort -n | tail -n 1) /secret/gitlab/backups/'

status:
	$(DOCKER) exec $(CONTAINER) bash -l -c "/opt/gitlab/bin/gitlab-ctl status"

rmvolumes:
	@-$(COMPOSE) rm -v -f

rmdata:
	rm -Rf config data logs

rmvenv:
	rm -Rf venv

rmbackup:
	rm -Rf backups secret_backups

destroy: kill rmdata rmvolumes

clean: destroy rmbackup rmvenv

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