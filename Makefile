all:
	./pinata-gpg-pull.sh || ./pinata-gpg-build.sh
	@echo Please run "make install"

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

install:
	@if [ ! -d "$(PREFIX)" ]; then echo Error: need a $(PREFIX) directory; exit 1; fi
	@mkdir -p $(BINDIR)
	cp pinata-gpg-forward.sh $(BINDIR)/pinata-gpg-forward
	cp pinata-gpg-pull.sh $(BINDIR)/pinata-gpg-pull
