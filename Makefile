# FIXME: This Makefile is not suffice.
# must write which are insuffice.

ISC_BIN=/edu/bin

all:
	@echo "'make isc' on isc to install icome client."
	@echo "'make ucome' on server to install/setup ucome."
	@echo "'make start' start the installed server ucome"
	@echo "acome from installed isc folder (hkimura only)"

isc:
	if [ ! -d /edu ]; then \
		@echo must exec on isc; \
	else \
		install -m 0755 icome.sh ${ISC_BIN}/icome; \
	fi

acome:
	@echo use ./acome to launch.

ucome-install:
	cp ucome.sh ucome.rb icome-common.rb /srv/ucome/bin
	chmod +x /srv/ucome/bin/ucome.{sh.rb}

# for debug. name of start is inappropriate.
ucome-debug:
	MONGO='mongodb://127.0.0.1/ucome' \
	UCOME='druby://150.69.90.82:9007' \
	./ucome.rb 2> /srv/ucome/log/ucome.log

stop:
	kill `ps ax | grep '[u]come' | awk '{print $$1}'`

clean:
	${RM} *~ .#* *.bak nohup.out
