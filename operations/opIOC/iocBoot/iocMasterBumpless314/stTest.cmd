#!../../bin/linux-x86/MasterBumpless314

## stTest.cmd for running on dev workstation, not on control network
## comment out asyn support

## You may have to change alias to something else
## everywhere it appears in this file

## IOC for testing the aliasing ability for the latest EPICS release

< envPaths

## Register all support components
dbLoadDatabase("../../dbd/MasterBumpless314.dbd")
MasterBumpless314_registerRecordDeviceDriver(pdbbase)

#drvAsynIPPortConfigure(const char *portName, const char *hostInfo,
#                           unsigned int priority, int noAutoConnect,
#                           int noProcessEos);
#drvAsynIPPortConfigure("ModInputread", "192.168.0.9:502", 0,1,1)
#drvAsynIPPortConfigure("ModCoilread00", "192.168.0.9:502", 0,1,1)
#drvAsynIPPortConfigure("ModCoilread01", "192.168.0.9:502", 0,1,1)

# Adding this line after looking through the Modbus/Asyn documentation
#modbusInterposeConfig("ModInputread", 1, 0, 1000)
#modbusInterposeConfig("ModCoilread00", 1, 0, 1000)
#modbusInterposeConfig("ModCoilread01", 1, 0, 1000)

# NOTE: We use octal numbers for the start address and length (leading zeros)
#       to be consistent with the PLC nomenclature.  This is optional, decimal
#       numbers (no leading zero) or hex numbers can also be used.

# Read bits..
# Read 1016 Inputs.  Function code=2.
#drvModbusAsynConfigure("In_Input00",   "ModInputread", 2,  0, 1016,    0,  100, "Modicon")

# Read 1400 coils in port 00
#drvModbusAsynConfigure("In_Coil00",   "ModCoilread00", 1,  0, 1400,    0,  100, "Modicon")
# Read then next 1383 coil in port 01
#drvModbusAsynConfigure("In_Coil01",   "ModCoilread01", 1,  1400, 1385,    0,  100, "Modicon")

# Adding Modicon Writes 21apr2009 ddr
# Use the following commands for TCP/IP
#drvAsynIPPortConfigure(const char *portName,
#                       const char *hostInfo,
#                       unsigned int priority,
#                       int noAutoConnect,
#                       int noProcessEos);
#drvAsynIPPortConfigure("MasterControlwrite", "192.168.0.9:502", 0,1,1)

#modbusInterposeConfig(const char *portName,
#                      int slaveAddress,
#                      modbusLinkType linkType,
#                      int timeoutMsec)
#modbusInterposeConfig("MasterControlwrite", 9, 0, 1000)

# NOTE: We use octal numbers for the start address and length (leading zeros)
#       to be consistent with the PLC nomenclature.  This is optional, decimal
#       numbers (no leading zero) or hex numbers can also be used.

# Write 256 bits in 1 command, starting at address 2784.
# Function code = 15.
#drvModbusAsynConfigure("MasterControlOut_Word", "MasterControlwrite", 15, 2784, 256,    0,  1,  "Modicon")

# Set up paths for bumpless reboot
#set_requestfile_path("/home/operations/opIOC/iocBoot/iocMasterBumpless314/autosaverequests")
#set_savefile_path("/home/operations/opIOC/iocBoot/iocMasterBumpless314/autosavefiles")




#Load Templates for Modicon Reads
dbLoadTemplate("read1400coilsAlias.substitutions")

dbLoadTemplate("read1383coilsAlias.substitutions")

dbLoadTemplate("read1016inputsAlias.substitutions")

#Load Templates for Modicon Writes
dbLoadTemplate("MasterControlOutAlias.substitutions")

#Load Record instances - NOT! This is the old genSub record
#dbLoadRecords("../../db/modWordWrite.db", "P=MOD1")

#Load calc records to prepare Modicon Writes - replaces genSub
dbLoadRecords("../../db/mod1_calc_outputs.db")

# Load IOC Heartbeat database
dbLoadRecords("../../db/IocHeartbeat.vdb", "SubSys=Master")

#This is here so you have time to see response to dbLoadRecords
epicsThreadSleep(10)

# now required in version 4.5
#set_pass0_restoreFile(auto_positions.sav)
#set_pass1_restoreFile(auto_settings.sav)

iocInit()

# save positions every five seconds
#create_monitor_set("auto_positions.req",5)
#save settings every 10 minutes
#create_monitor_set("auto_settings.req",600)
