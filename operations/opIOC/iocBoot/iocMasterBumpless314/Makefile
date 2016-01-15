TOP = ../..
include $(TOP)/configure/CONFIG
ARCH = linux-x86
TARGETS = envPaths
include $(TOP)/configure/RULES.ioc

# make in opIOC/ runs this command
install:
	./get_substitutions.sh

# make issues warning: ignoring old commands for target `clean'
clean:
	rm envPaths *.substitutions
