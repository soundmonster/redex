registry := soundmonster
image_name := redex
tag := $(shell git describe --always --tags)

all: build tag push

build:
	docker build -t $(image_name) .

tag:
	docker tag $(image_name) $(registry)/$(image_name):latest
	docker tag $(image_name) $(registry)/$(image_name):$(tag)

push:
	docker push $(registry)/$(image_name)
