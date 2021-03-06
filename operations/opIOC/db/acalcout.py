"""
acalcout.py - make acalcout records to pack output bits into waveform:
               python acalcout.py > mod1_calc_outputs.db
"""
import string
import math


# slice record prefix
# Strings to fill in:
#  Slice number for PV name %03d
#  NELM %d
#  CALC expression %s
slice = """record(acalcout, "MOD1:Waveform:Slice%03d:Calc") {
  field(SCAN, ".1 second")
  field(NELM,  %d)
  field(CALC, "%s") # limit 36 char"""

# Coil record detail line
# Strings to fill in:
#  Input name INA, INB $s 
#  Coil number for PV name %04d
inp_s = '  field(INP%s, "MOD1:Coil%04d:Write")'


# merge record prefix
# Only 12 inputs AA ... LL, only 12 slices * 2 bits/slice = 24bits
#  so we'll need 368/24 = 15 records + 1 unfilled record
# Strings to fill in:
#  slice number for PV name %02d
#  NELM %d
#  CALC expression, usually AA+BB+CC+DD+EE+FF+GG+HH+II+JJ+KK+LL
merge = """record(acalcout, "MOD1:Waveform:Merge%02d:Calc"){
  field(SCAN, ".1 second")
  field(NELM,  %d)
  field(CALC, "%s") # 36 char limit"""

# merge record detail line
# Strings to fill in:
#  Input name INAA ... INLL $s 
#  slice number for PV name %03d
inp_m = '  field(IN%s, "MOD1:Waveform:Slice%03d:Calc.AVAL")'

# merge record prefix
# Only 12 inputs AA ... LL, only 12 slices * 2 bits/slice = 24bits
#  so we'll need 368/24 = 15 records + 1 unfilled record
# Strings to fill in:
#  slice number for PV name %02d
#  NELM %d
#  CALC expression, usually AA+BB+CC+DD+EE+FF+GG+HH+II+JJ+KK+LL
merge2 = """record(acalcout, "MOD1:Waveform:2ndMerge%02d:Calc"){
  field(SCAN, ".1 second")
  field(NELM,  %d)
  field(CALC, "%s") # 36 char limit"""


# merge record detail line
# Strings to fill in:
#  Input name INAA ... INLL $s 
#  slice number for PV name %03d
inp_m2 = '  field(IN%s, "MOD1:Waveform:Merge%02d:Calc.AVAL")'

# Need two of these records to input all 16 acalcout records.
# output record prefix
# Strings to fill in:
#  NELM %d
#  CALC expression, AA+BB+ ....
out = """record(acalcout, "MOD1:Waveform:Output:Calc") {
  field(SCAN, ".1 second")
  field(NELM,  %d)
  field(CALC, "%s")
  field(OOPT, "Every Time")
  field(DOPT, "Use CALC")
  field(OUT,  "MOD1:CnOutWArray.VAL PP NMS")"""

# output record detail line
#  Input name INAA ... INLL $s 
#  slice number for PV name %03d
inp_o = '  field(IN%s, "MOD1:Waveform:2ndMerge%02d:Calc.AVAL")'

# NOW SEND ALL 281 bits - MUST revise NELM in st.cmd and MOD1:CnOutWArray
# In first version the number of bits should be 256 to agree with st.cmd
# drvModBusAsynConfigure(... "MasterControlWrite", 15, 2784, 256, ...)
# and also to agree with NELM in MOD1:CnOutWArray 
# set via intarray_out.template in MasterControlOutAlias.substitutions
# Notice that substitutions file actually defines 281 bits, not 256
# Apparently the last 25 bits did not get sent to MOD1 in first version

# Test
#first = 803    # first MOD2 write coil number
#last =  830    # last MOD1 write coil number

first = 2769  # first MOD1 write coil number
#last =  3040  # last  MOD1 write coil number - first 256 bits only, like genSub
last = 3136 # last MOD1 write coil number in MasterControlOutAlias.substitutions

nelm = last - first + 1  # inclusive

print '# Generated by: python acalcout.py > mod1_calc_outputs.db'
print

# slice records
nbits = 2 # bits per slice, set by 36 char limit in CALC field
icoil = 0
islice = 0
nslice = (nelm / nbits) + bool(nelm % nbits)
while icoil < nelm:
    # print a slice record
    ntail = nelm - islice*nbits
    ninp = nbits if ntail >= nbits else ntail
    calc = '+'.join(['ARR(%s){%d,%d}' % (string.ascii_uppercase[i],
                                         icoil+i, icoil+i+1) 
                     for i in range(ninp)])
    print slice % (islice, nelm, calc)
    inp = 0
    while inp < ninp:
        inx = string.ascii_uppercase[inp]
        print inp_s % (inx, first+icoil)
        icoil += 1
        inp += 1
    print '}'
    islice += 1

# merge records
islice = 0
imerge = 0
maxinp = 12 # max slices per merge record INAA ... INLL
nper = maxinp*nbits # max bits/record = slices/record * bits/slice
nmerge = nelm/nper # n merge records = nelm bits / bits/record
nmerge += bool(nelm % nper) # left overs
#print 'nmerge %d' % nmerge # DEBUG
while islice < nslice:
    # print a merge record
    # print 'imerge %d' % imerge # DEBUG
    ninp = maxinp if imerge < nmerge-1 else nslice - islice
    calc = '+'.join([c*2 for c in string.ascii_uppercase[:ninp]])
    print merge % (imerge, nelm, calc)
    inp = 0
    while inp < ninp:
        # print an INXX field
        inxx = string.ascii_uppercase[inp]*2
        print inp_m % (inxx, islice)
        islice += 1
        inp += 1
    print '}'
    print
    imerge += 1


# output record

islice = 0
imerge = 0
maxinp = 12 # max slices per merge record INAA ... INLL
nper = maxinp*nbits # max bits/record = slices/record * bits/slice
nmerge = nelm/nper # n merge records = nelm bits / bits/record
nmerge += bool(nelm % nper) # left overs
#print 'nmerge %d' % nmerge # DEBUG
maxrec=int(math.ceil(float(nmerge)/maxinp))

while islice < nmerge:
    # print a merge record
    # print 'imerge %d' % imerge # DEBUG
    ninp = maxinp if imerge < maxrec-1 else nmerge - islice
    calc = '+'.join([c*2 for c in string.ascii_uppercase[:ninp]])
    print merge2 % (imerge, nelm, calc)
    inp = 0
    while inp < ninp:
        # print an INXX field
        inxx = string.ascii_uppercase[inp]*2
        print inp_m2 % (inxx, islice)
        islice += 1
        inp += 1
    print '}'
    print
    imerge += 1

assert imerge <= maxinp # so we only need one output record
calc = '+'.join([c*2 for c in string.ascii_uppercase[:imerge]])
print out % (nelm, calc)
for imerge in range(maxrec):
    inxx = string.ascii_uppercase[imerge]*2
    print inp_o % (inxx, imerge)
print '}'

