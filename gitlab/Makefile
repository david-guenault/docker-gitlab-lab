#!/usr/bin/make

PYTHON=/usr/bin/python3
DOCKER=/usr/bin/docker
BASE=$$(pwd)
COMPOSE=$$(pwd)/venv/bin/docker-compose
CONTAINER=gitlab

venv: rmvenv
	$(PYTHON) -m venv venv
	./venv/bin/pip install --upgrade pip wheel
	./venv/bin/pip install docker-compose	

create:
	export GITLAB_HOME=$(BASE) && \
	$(COMPOSE) up -d && \
	mkdir -p secret_backups && \
	$(DOCKER) exec -t $(CONTAINER) mkdir -p /secret/gitlab/backups

kill:
	@-$(COMPOSE) kill

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
	@-$(DOCKER) exec -ti $(CONTAINER) ls -1 /var/opt/gitlab/backups | grep "gitlab_backup\.tar" | sed -e "s/_gitlab_backup\.tar//g"
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

.PHONY: clean create kill logs ps reconfigure rm shell start status stop venv status clean rmvolumes rmvenv rmdata rmbackup