#!../../bin/linux-x86/MasterBumpless314

## You may have to change alias to something else
## everywhere it appears in this file

## IOC for testing the aliasing ability for the latest EPICS release

< envPaths

##cd ${TOP}/iocBoot/iocMasterBumpless314

epicsThreadSleep(5)



## Register all support components
dbLoadDatabase("../../dbd/MasterBumpless314.dbd")
MasterBumpless314_registerRecordDeviceDriver(pdbbase)











####################################################################################################################################
#########################Configure Asyn Ports Connected to the Extractor SAM, PSHV/SEPTUM, EMC, PSARC/GasFlow Meter
####################################################################################################################################

##                  drvAsynIPPortConfigure("portName","hostAddress",priority,noAutoConnect,noProcessEOS)

##                  portName = Any Name that makes sense (Can be more than one port(name) per IP address
##                  hostAddress = IP address or name, and port # on tne network.  Assumed TCP unless specified - See documentation for other than TCP
##                  priority = Asyn I/O thread priority.  0 or missing = ThreadPriorityMedium
##                  noAutoConnect = Autoconnect status. 0 or missing = Autoconnect after disconnect or if connect timeout at boot.
##                  noProcessEOS = EOS in and out are specified if 0 or missing


#drvAsynIPPortConfigure(const char *portName, const char *hostInfo,
#                           unsigned int priority, int noAutoConnect,
#                           int noProcessEos);
drvAsynIPPortConfigure("ModInputread", "192.168.0.9:502", 0,0,1)
drvAsynIPPortConfigure("ModCoilread00", "192.168.0.9:502", 0,0,1)
drvAsynIPPortConfigure("ModCoilread01", "192.168.0.9:502", 0,0,1)
drvAsynIPPortConfigure("MasterControlwrite", "192.168.0.9:502", 0,0,1)









##################################################################################################################################################
###############Allow previous IP Ports created to support Modbus Protocol
##################################################################################################################################################
##                  modbusInterposeConfig("portName", linkType, timeOutmSec, writeDelaymSec)

##                  portName = Name of previously configured IP port to attach Modbus communication to
##                  LinkType = 0 - TCP/IP
##                                   1 - RTU Serial
##                                   2 - ASCII Serial
##                  timeOutmSec = time in milliseconds for asynOctet has to complete read/write operations before timeout is reached and operation is
##                            aborted
##                  writeDelayMSec = minimum delay in milliseconds between modbus writes, useful for RTU and ascii comm, set to 0 for tcp comm.

# modbus-2-2 args: portName, linkType, timeoutMsec, writedelayMsec 
# no slaveAddress arg, writedelayMsec only used for serial RTU devices
modbusInterposeConfig("ModInputread", 0, 1000, 0)
modbusInterposeConfig("ModCoilread00", 0, 1000, 0)
modbusInterposeConfig("ModCoilread01", 0, 1000, 0)
modbusInterposeConfig("MasterControlwrite", 0, 1000, 0)





##################################################################################################################################################
#####Configure Modbus Ports and assign them to IP Ports.  More than 1 Modbus port may be assigned to an IP Port
####################################################################################################################################
#drvModbusAsynConfigure(
#
#                      portName, - name of Modbus port to create
#
#                      tcpPortName, - name of previously created IP port to use  
#
#                      slaveAddress - For TCP communication the PLC ignores it so set to 0
#
#                      modbusFunction, - 1 Read Coil Status
#                                      - 2 Read Input Status
#                                      - 3 Read Holding Register
#                                      - 4 Read Input Register
#                                      - 5 Write Single Coil
#                                      - 6 Write Single Register
#                                      - 7 Read Exception Status
#                                      - 15 Write Multiple Coils (Requires additional Gensub code to put values in waveform record)
#                                      - 16 Write Multiple Registers (Requires additional Gensub code to put values in waveform record)
#                                      - 17 Report Slave ID
#
#                      modbusStartAddress, - Address in decimal or octal (add leading 0 if using octal e.g. 0177)
#
#                      modbusLength,  - number of 16 bit words to access for function codes 3,4,6,16, number of bits for codes 1,2,5,15
#
#                      dataType,     - Data format
#                                    - 0 UINT16, Unsigned 16bit Binary
#                                    - 1 INT16SM, 16 bit Binary, sign and magnitude.  Bit 15 is sign, 0-14 magnitude
#                                    - 2 BCD, unsigned
#                                    - 3 BCD, signed
#                                    - 4 INT16, signed 2's compliment
#                                    - 5 INT32_LE, 32 bit integer, little endian
#                                    - 6 INT32_LE, 32 bit integer, big endian
#                                    - 7 FLOAT32_LE, 32 bit floating point, little endian
#                                    - 8 FLOAT32_LE, 32 bit floating point, big endian
#                                    - 9 FLOAT64_LE, 64 bit floating point, little endian
#                                    - 10 FLOAT64_LE, 64 bit floating point, big endian
#
#                      pollMsec, - Polling delay time for read functions (This is the time resolution when using I/O interrupt scanning)
#
#                      plcType, - Any name, used in asynReport
#
## 

# NOTE: We use octal numbers for the start address and length (leading zeros)
#       to be consistent with the PLC nomenclature.  This is optional, decimal
#       numbers (no leading zero) or hex numbers can also be used.

# modbus-2-2 args: portName, tcpPortName, slaveAddress, modbusFunction, 
#                    modbusStartAddress, ModbusLength, datatype, pollMsec, plcType
# Read 1016 Inputs.  Function code=2.
drvModbusAsynConfigure("In_Input00", "ModInputread", 0, 2, 0, 1088, 0, 100, "Modicon")
drvModbusAsynConfigure("In_Coil00", "ModCoilread00", 0, 1, 0, 1400, 0, 100, "Modicon")
drvModbusAsynConfigure("In_Coil01", "ModCoilread01", 0, 1, 1400, 1368, 0, 100, "Modicon")
drvModbusAsynConfigure("MasterControlOut_Word", "MasterControlwrite", 0, 15, 2768, 368, 0, 100, "Modicon")



set_requestfile_path("autosaverequests")
set_savefile_path("../../../var/autosavefiles")





#Load Templates for Modicon Reads
dbLoadTemplate("read1400coilsAlias.substitutions")
dbLoadTemplate("read1383coilsAlias.substitutions")
dbLoadTemplate("read1088inputsAlias.substitutions")
dbLoadTemplate("MasterControlOutAlias.substitutions")





#Load calc records to prepare Modicon Writes - replaces genSub
dbLoadRecords("../../db/mod1_calc_outputs.db")



#Load records to control SB1/2 Lamps
dbLoadRecords("../../db/StandbyLevelsCyclotron.vdb")



#Monitors signals for Alerts
dbLoadRecords("../../db/MonitorAlerts.vdb", "SubSys=Master")


# Load IOC Heartbeat database
dbLoadRecords("../../db/IocHeartbeat.vdb", "SubSys=Master")



# now required in version 4.5
set_pass0_restoreFile(auto_positions.sav)
set_pass1_restoreFile(auto_settings.sav)





#response to the error callbackRequest: cbLow ring buffer full.
#I believe when the iocInit is run, there are to many changed values 
# and too many callbacks for I/O scan. THus we end up getting stale data from the modicon.
#see http://www.aps.anl.gov/epics/tech-talk/2010/msg00133.php
callbackSetQueueSize(4225)



iocInit()





# save positions every five seconds
create_monitor_set("auto_positions.req",5)
#save settings every 10 minutes
create_monitor_set("auto_settings.req",600)
