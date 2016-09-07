# This Makefile is not suffice.

REPOS=https://github.com/hkim0331/icome8.git

all:
	@echo "'make icome' on isc"
	@echo "'make acome' on isc"
	@echo "'make ucome' on vm2016"
	@echo "'make clean' "

# ISC
icome:
	(cd ~ && git clone ${REPOS})
	(cd ~/icome8 && install -m 0755 icome /edu/bin/)
	(cd ~/icome8 && install -m 0755 acome ~/bin/)

# VM2016
ucome:
	(cd /opt && git clone ${REPOS})
	mkdir -p /srv/icome8/upload

clean:
	${RM} *~ .#* *.bak nohup.out







