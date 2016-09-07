# This Makefile is not suffice.

all:
	@echo "'make icome' on isc"
	@echo "'make acome' on isc"
	@echo "'make ucome' on vm2016"
	@echo "'make clean' "

isc: icome acome

icome:
	install -m 0755 icome.sh /edu/bin/icome
	install -m 0755 icome.rb /home/t/hkimura/bin/icome8.rb

ucome:
	install -m 0644 VERSION /opt/icome8
	install -m 0755 ucome.rb /opt/icome8/bin
	mkdir -p /srv/icome8/upload
	sudo install -m 0755 ucome.service /etc/init.d/ucome
	sudo install -m 0755 ucome-backup.sh /etc/cron.weekly/ucome-backup
	sudo update-rc.d ucome defaults

acome:
	install -m 0755 acome.rb
clean:
	${RM} *~ .#* *.bak nohup.out
#	${RM} -r upload/* # too much?







