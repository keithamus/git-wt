PREFIX ?= /usr/local

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 bin/git-worktree-share $(DESTDIR)$(PREFIX)/bin/git-worktree-share

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/git-worktree-share

test:
	bash test/test-git-worktree-share.sh

.PHONY: install uninstall test
