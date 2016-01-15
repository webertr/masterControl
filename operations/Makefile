# Makefile at top of CNTS operations tree

TOP = .
DIRS := bin etc opIOC sbin tmp var

all: perms 


#foo: $(DIRS)
#	for dir in $(DIRS); do echo $$dir; done

perms: $(DIRS)
	find . -type d -exec chmod 2775 {} \; 
	find . -type f -exec chmod 2664 {} \; 
	find . -type d -name "bin" -exec chmod -R 2775 {} \; 
	find . -type d -name "sbin" -exec chmod -R 2775 {} \; 
	find . -type d -name "init.d" -exec chmod -R 2775 {} \; 
	find . -type d -name "tmp" -exec chmod -R 1777 {} \; 
	find . -type f -name "st.cmd" -exec chmod -R 2775 {} \; 

reset: $(DIRS)
	find . -type d -exec chmod g-s {} \; 
	find tmp -type d -exec chmod o-tw {} \; 
	find . -type f -exec chmod g-s {} \; 

.PHONY: Makefile perms reset

