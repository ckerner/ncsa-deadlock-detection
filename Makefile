GPFSDIR=$(shell dirname $(shell which mmlscluster))
CURDIR=$(shell pwd)
LOCLDIR=/var/mmfs/etc 

install: 
	cp -pf $(CURDIR)/ncsa_deadlock_detection.sh $(LOCLDIR)/ncsa_deadlock_detection.sh

clean:
	rm -Rf ${LOCLDIR}/ncsa_deadlock_detection.sh

.FORCE:


