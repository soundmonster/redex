registry = soundmonster
image_name = redex

all: build tag push

build:
	docker build -t $(image_name) .

tag:
	docker tag $(image_name) $(registry)/$(image_name)

push:
	docker push $(registry)/$(image_name)

