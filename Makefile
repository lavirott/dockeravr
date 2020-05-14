USERNAME=enactproject
NAME=dockeravr
RELEASE=latest

all: build publish

build: Dockerfile
	docker build -t $(USERNAME)/$(NAME):$(RELEASE) $<

login:
	docker login --username genesisenact

publish:
	docker push $(USERNAME)/$(NAME):$(RELEASE)