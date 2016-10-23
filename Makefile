SUBDIRS:=$(shell find * -mindepth 1 -maxdepth 1 -name Makefile -printf '%h ')

.PHONY: $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) $(MAKE_FLAGS) -C $@
