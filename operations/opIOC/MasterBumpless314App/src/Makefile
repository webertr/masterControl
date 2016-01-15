TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

PROD_IOC = MasterBumpless314
DBD = MasterBumpless314.dbd

MasterBumpless314_DBD += commonInclude.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
MasterBumpless314_SRCS += MasterBumpless314_registerRecordDeviceDriver.cpp
MasterBumpless314_SRCS += MasterBumpless314Main.cpp

MasterBumpless314_LIBS += asyn calc sscan modbus autosave stream

#===========================


MasterBumpless314_LIBS += $(EPICS_BASE_IOC_LIBS)
#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
