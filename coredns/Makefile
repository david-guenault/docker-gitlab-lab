#!/usr/bin/make

PYTHON=/usr/bin/python3
DOCKER=/usr/bin/docker
COMPOSE:=$(shell realpath $$(pwd)/venv/bin/docker-compose)
CONTAINER=coredns
IMAGENAME=coredns


create:
	$(COMPOSE) up -d 

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

################################################################
########################   UTILITIES   #########################
################################################################

build:
	@-rm -Rf ./coredns ./coredns.git
	git clone git@github.com:coredns/coredns.git coredns.git
	cd coredns.git && \
	docker run --rm -i -t -v $$(pwd):/v -w /v golang:1.16 make && \
	cp coredns ../ && \
	rm -Rf ./coredns.git

build_docker_image:
	$(DOCKER) build --no-cache --progress auto --force-rm --rm -t $(IMAGENAME) .

help:
	$(DOCKER) exec -ti $(CONTAINER) --help

shell:
	$(DOCKER) exec -ti $(CONTAINER) /bin/bash

venv: rmvenv
	$(PYTHON) -m venv venv
	./venv/bin/pip install --upgrade pip wheel
	./venv/bin/pip install docker-compose	

variables:
	@-echo $(PYTHON)
	@-echo $(DOCKER)
	@-echo $(COMPOSE)

################################################################
######################## REMOVE #########################
################################################################

rm:
	@-$(COMPOSE) rm -f

remove_orphaned:
	@-$(DOCKER) volume rm $$(docker volume ls -qf dangling=true)
	@-$(DOCKER) rmi $$($(DOCKER) images -f dangling=true -q)

rmvenv:
	@-sudo rm -Rf venv

destroy: kill rm rmvenv remove_orphaned
	@-rm -f ./coredns

