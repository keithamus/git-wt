PREFIX ?= /usr/local

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 bin/git-wt $(DESTDIR)$(PREFIX)/bin/git-wt

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/git-wt

test:
	bash test/test-git-wt.sh

.PHONY: install uninstall test
