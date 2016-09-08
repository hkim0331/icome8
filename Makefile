# This Makefile is not suffice.
#
# git clone https://github.com/hkim0331/icome8.git
# もしくは
# git clone git@github.com:hkim0331/icome8.git
# したディレクトリで実行すること。

all:
	@echo \'make icome\' on isc
	@echo \'make ucome\' on vm2016

icome:
	if [ ! -d /edu/lib/icome8 ]; then
		mkdir /edu/lib/icome8
	fi
	install -m 0755 icome /edu/lib/
	install -m 0644 icome-common.rb /edu/lib
	ln -s /edu/bin/icome /edu/lib/icome8/icome

acome:
	@echo use ./acome to launch.

ucome:
	(cd /srv && ln -sf /home/hkim/icome8 icome8)
	./ufw.sh

clean:
	${RM} *~ .#* *.bak nohup.out
