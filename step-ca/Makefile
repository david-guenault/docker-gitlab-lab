#!/usr/bin/make

DOCKER=/usr/bin/docker
BASE:=$(shell cat env.sh | grep HOME | awk -F= '{print $$2}')
COMPOSE:=$(shell realpath $(BASE)/venv/bin/docker-compose) --env-file ./env.sh
CONTAINER:=$(shell cat env.sh | grep CONTAINER | awk -F= '{print $$2}')
PASS:=$(shell cat env.sh | grep STEPCA_INIT_PASSWORD | awk -F= '{print $$2}')
PROVISIONNER_NAME:=$(shell cat env.sh | grep STEPCA_INIT_PROVISIONER_NAME | awk -F= '{print $$2}')
STEP_CA_CERTIFICATE_DURATION:=$(shell cat env.sh | grep STEP_CA_CERTIFICATE_DURATION= | awk -F= '{print $$2}')
STEP_CA_MAX_CERTIFICATE_DURATION=$(shell cat env.sh | grep STEP_CA_MAX_CERTIFICATE_DURATION= | awk -F= '{print $$2}')

init:
	$(COMPOSE) up -d
	mkdir -p step-ca backups
	sleep 5
	$(DOCKER) exec -ti $(CONTAINER) bash -l -c "echo $(PASS) > /home/step/credential"

venv:
	python3 -m venv venv
	./venv/bin/pip3 install --upgrade pip wheel
	./venv/bin/pip3 install --upgrade docker-compose

variables:
	@-echo $(DOCKER)
	@-echo $(BASE)
	@-echo $(COMPOSE)
	@-echo $(CONTAINER)
	@-echo $(PASS)
	@-echo $(PROVISIONNER_NAME)
	@-echo $(STEP_CA_CERTIFICATE_DURATION)

test: clean venv variables init
	sleep 5
	make tls-cert FQDN=my.domain.tld
	make backup
	make destroy
	make init
	sleep 5
	make restore-backup BACKUP=$(shell ls -1 backups)

remove_orphaned_volumes:
	@-$(DOCKER) volume rm $$(docker volume ls -qf dangling=true) && \
	exit 0

kill:
	$(COMPOSE) kill

clean: destroy rmbackups remove_orphaned_volumes

rmfile:
	sudo rm -Rf step-ca

rmbackups:
	sudo rm -Rf backups tmpbackup

rm:
	@-$(COMPOSE) rm -f

rmvenv:
	rm -Rf  venv

destroy: kill rm rmfile remove_orphaned_volumes rmvenv

dump-config:
	@-$(COMPOSE) exec step-ca cat /home/step/config/ca.json 

get-fingerprint:
	@-$(DOCKER) exec -ti $(CONTAINER) step certificate fingerprint /home/step/certs/root_ca.crt

ca-chain: sync
	cd step-ca/home/step/certs && \
	rm -f ca_chain.crt && \
	touch ca_chain.crt && \
	cat root_ca.crt >> ca_chain.crt && \
	cat intermediate_ca.crt >> ca_chain.crt

tls-cert:
	@-$(DOCKER) exec -ti $(CONTAINER) bash -l -c "cd /home/step; step ca certificate --force --not-after=$(STEP_CA_CERTIFICATE_DURATION) --provisioner=$(PROVISIONNER_NAME) --provisioner-password-file=./credential $(FQDN) $(FQDN).crt $(FQDN).key"
	make sync
	cd step-ca/home/step && \
	cat $(FQDN).crt && \
	cat $(FQDN).key

tls-cert-renew: 
	@-$(DOCKER) exec -ti $(CONTAINER) bash -l -c "cd /home/step; step ca renew --force $(FQDN).crt $(FQDN).key"
	make sync
	cd step-ca/home/step && \
	cat $(FQDN).crt && \
	cat $(FQDN).key
	make sync

sync:
	@-$(DOCKER) cp $(CONTAINER):/home ./step-ca/


set-tls-cert-duration: sync
	cat step-ca/home/step/config/ca.json | jq --arg key claims --argjson value "{}" '.authority[$$key]=$$value' | jq --arg key maxTLSCertDuration --arg value $(STEP_CA_MAX_CERTIFICATE_DURATION) '.authority.claims[$$key]=$$value' > /tmp/ca.json
	cat /tmp/ca.json > step-ca/home/step/config/ca.json	
	cat /tmp/ca.json | jq '.authority.claims'
	make update-config

update-config:
	@-$(DOCKER) cp ./step-ca/home/step/config/ca.json $(CONTAINER):/home/step/config/ca.json
	make stop
	make start
	sleep 5
	make sync

health:
	@-$(DOCKER) exec -ti $(CONTAINER) bash -l -c "step ca health"

backup: sync
	cd backups && \
	tar czvf step-ca.$$(date +%s).tar.gz ../step-ca

list-backups:
	@-ls -1 backups

ls: 
	@-$(DOCKER) exec -ti $(CONTAINER) bash -l -c "ls -la /home/step"

restore-backup:
	@-if [ -z "$(BACKUP)" ]; then echo "You must specify a backup file"; exit 1; fi
	@-mkdir -p tmpbackup && \
	cd tmpbackup && \
	tar xvf ../backups/$(BACKUP) && \
	cd .. && \
	docker cp tmpbackup/step-ca/home $(CONTAINER):/
	rm -Rf tmpbackup
	make stop
	make start
	sleep 10
	make health

shell:
	@-$(DOCKER) exec -ti $(CONTAINER) bash

logs:
	@-$(COMPOSE) logs -f

stop:
	@-$(COMPOSE) stop

ps:
	@-$(COMPOSE) ps

start:
	@-$(COMPOSE) start

.PHONY: 