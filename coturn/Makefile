NAME = oriaks/coturn
VERSION = 4.5

.PHONY: all build tag_latest

all: build tag_latest

build:
	docker build -t $(NAME):$(VERSION) --rm .

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest
