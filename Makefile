PREFIX = /usr

INSTALL_ROOT := $(DESTDIR)$(PREFIX)/share/deepin-share


all:

install:
	mkdir -p $(INSTALL_ROOT)
	cp -r src qmls images $(INSTALL_ROOT)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	ln -s $(PREFIX)/share/deepin-share/src/deepin-share $(DESTDIR)$(PREFIX)/bin/deepin-share
	mkdir -p $(DESTDIR)$(PREFIX)/share/dbus-1/services
	cp *.service $(DESTDIR)$(PREFIX)/share/dbus-1/services
