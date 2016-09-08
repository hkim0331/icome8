# This Makefile is not suffice.
#
# git clone https://github.com/hkim0331/icome8.git
# もしくは
# git clone git@github.com:hkim0331/icome8.git
# したディレクトリで実行すること。

ISC=/edu/lib/icome8

all:
	@echo \'make icome\' on isc
	@echo \'make ucome\' on vm2016

isc:
	if [ ! -d ${ISC} ]; then \
		mkdir ${ISC} \
	fi
	install -m 0755 icome icome.rb ${ISC}
	install -m 0644 icome-common.rb ${ISC}
	ln -s /edu/bin/icome ${ISC}/icome

acome:
	@echo use ./acome to launch.

ucome:
	(cd /srv && ln -sf /home/hkim/icome8 icome8)
	./ufw.sh

clean:
	${RM} *~ .#* *.bak nohup.out
