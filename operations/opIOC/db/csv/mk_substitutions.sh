# From each .csv, generate .substitution and mv it to $DEST directory
CMD="perl ModTranslate.perl"
# FILE1 etc. are implicitly defined in ModTranslate.perl
FILE1=read1400coilsAlias.substitutions
FILE2=read1383coilsAlias.substitutions
FILE3=read1016inputsAlias.substitutions
FILE4=MasterControlOutAlias.substitutions
DEST=../../iocBoot/iocMasterBumpless314
# do it
echo 1 | $CMD
echo 2 | $CMD
echo 3 | $CMD
echo 4 | $CMD
mv $FILE1 $FILE2 $FILE3 $FILE4 $DEST
