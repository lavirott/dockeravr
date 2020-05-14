ACCOUNT=enactproject
NAME=dockeravr
TAG=latest

DOCKERHUB_USERNAME=genesisenact

all: build publish

build: Dockerfile
	docker build -t $(ACCOUNT)/$(NAME):$(TAG) $<

login:
	docker login --username $(DOCKERHUB_USERNAME)

publish:
	docker push $(ACCOUNT)/$(NAME):$(TAG)