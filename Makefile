# This Makefile is not suffice.
#
# git clone https://github.com/hkim0331/icome8.git
# もしくは
# git clone git@github.com:hkim0331/icome8.git
# したディレクトリで実行すること。

ISC=/edu/lib/icome8
ISC_BIN=/edu/bin

all:
	@echo "* 'make isc' on isc to install icome."
	@echo "   use acome from icome8 installed directory."
	@echo "* 'make vm2016' on vm2016 to install ucome."

isc:
	if [ ! -d /edu ]; then \
		echo must exec on isc; \
		exit 1; \
	fi
	if [ ! -d ${ISC} ]; then \
		mkdir ${ISC}; \
	fi
	install -m 0755 icome.rb ${ISC}
	install -m 0644 icome-common.rb ${ISC}
	install -m 0644 icome-ui.rb ${ISC}
	install -m 0755 icome ${ISC_BIN}

acome:
	@echo use ./acome to launch.

vm2016:
	@echo "install ucome by 'cd /srv && ln -sf /home/hkim/icome8 icome8'"
	@echo "check ucome port are opened './ufw.sh'"

start: ucome_start

ucome_start:
	nohup ./ucome 2>/dev/null &

stop: ucome_stop

ucome_stop:
	kill `ps ax | grep '[u]come' | awk '{print $$1}'`

clean:
	${RM} *~ .#* *.bak nohup.out


