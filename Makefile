# This Makefile is not suffice.

all:
	@echo "'make icome' on isc"
	@echo "'make acome' on isc"
	@echo "'make ucome' on vm2016"
	@echo "'make clean' "

# ISC
icome:
	(cd ~ && git clone https://github.com/hkim0331/icome8.git)
	(cd ~/icome8 && install -m 0755 icome /edu/bin/)
	(cd ~/icome8 && install -m 0755 acome ~/bin/)

# VM2016
ucome:
	(cd /opt && git clone https://github.com/hkim0331/icome8.git)
	mkdir -p /srv/icome8/upload


clean:
	${RM} *~ .#* *.bak nohup.out







