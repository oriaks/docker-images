NAME = oriaks/pydio
VERSION = 7.0

.PHONY: all build tag_latest

all: build tag_latest

build:
	docker build -t $(NAME):$(VERSION) --rm .

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest
