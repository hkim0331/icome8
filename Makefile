# FIXME: This Makefile is not suffice.
# must write which are insuffice.

ISC_BIN=/edu/bin

all:
	@echo "'make isc' on isc to install icome client."
	@echo "'make ucome-install' on server to install/setup ucome."
	@echo "'make start' start the installed server ucome"
	@echo "acome from installed isc folder (hkimura only)"

isc:
	if [ ! -d /edu ]; then \
		@echo must exec on isc; \
	else \
		install -m 0755 icome.sh ${ISC_BIN}/icome; \
		install -m 0755 bin/gtypist-check.rb  ${ISC_BIN}/; \
	fi

acome:
	@echo use ${PWD}/acome to launch.

ucome-install:
	cp ucome.rb icome-common.rb /srv/ucome/bin
	chmod +x /srv/ucome/bin/ucome.rb

stop:
	kill `ps ax | grep '[u]come' | awk '{print $$1}'`

clean:
	${RM} *~ .#* *.bak nohup.out
