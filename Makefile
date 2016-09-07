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
	install -m 0755 icome /edu/bin
	install -m 0644 icome-common.rb /edu/bin

acome:
	@echo use ./acome to launch.

ucome:
	(cd /srv && ln -sf /home/hkim/icome8 icome8)
	./ufw.sh

clean:
	${RM} *~ .#* *.bak nohup.out
