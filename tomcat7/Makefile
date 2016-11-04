NAME = oriaks/tomcat
VERSION = 7

.PHONY: all build tag_latest

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest
