# This Makefile is not suffice.
#
# git clone https://github.com/hkim0331/icome8.git
# もしくは
# git clone git@github.com:hkim0331/icome8.git
# したディレクトリで実行すること。

#ISC=/edu/lib/icome8
ISC_BIN=/edu/bin

all:
	@echo "'make isc' on isc to install icome client."
	@echo "'make ucome' on server to install/setup ucome."
	@echo "'make start' start the installed server ucome"
	@echo "acome from installed isc folder (hkimura only)"

isc:
	if [ ! -d /edu ]; then \
		@echo must exec on isc; \
	else ;\
		install -m 0755 icome ${ISC_BIN}; \
	fi

acome:
	@echo use ./acome to launch.

ucome:
	install ucome.rb icome-common.rb /srv/ucome/bin

start:
	MONGO='mongodb://127.0.0.1/ucome' \
	UCOME='druby://150.69.90.81:9007' \
	./ucome.rb 2> /srv/ucome/log/ucome.log

stop:
	kill `ps ax | grep '[u]come' | awk '{print $$1}'`

clean:
	${RM} *~ .#* *.bak nohup.out
