# FIXME: This Makefile is not enough.
# must write which are insuffice.

ISC_BIN=/edu/bin

all:
	@echo "'make isc' on isc to install icome client."
	@echo "'make ucome' on server to install/setup ucome."
	@echo "'make ucome-start' start the installed server ucome"
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

ucome: srv-ucome systemd-ucome

srv-ucome:
	mkdir -p /srv/ucome/bin /srv/ucome/log
	chown ubuntu:ubuntu /srv/ucome/log
	cp ucome.sh ucome.rb icome-common.rb /srv/ucome/bin
	chmod +x /srv/ucome/bin/ucome.rb /srv/ucome/bin/ucome.sh

systemd-ucome:
	sudo cp ucome.service /lib/systemd/system/
	sudo systemctl enable ucome.service

ucome-start:
	systemctl start ucome
#	[ -e /srv/ucome/bin/ucome.sh ] && /srv/ucome/bin/ucome.sh &

ucome-stop:
	systemstp stop ucome
#	kill `ps ax | grep '[u]come' | awk '{print $$1}'`

clean:
	${RM} *~ .#* *.bak nohup.out
