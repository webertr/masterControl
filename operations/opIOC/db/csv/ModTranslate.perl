#!/usr/bin/perl
# Modicon Translation program to go from csv file to the appropriate substituion files
# Sep, 20th, 2012. Put / in front of dollar signs, and added
#"file \"\$(ASYN)/db/asynRecord.db\" { pattern\n";
#along with comment to selections 1 and 2

print "This program translates the Modicon csv files to the appropriate substitution files...\n";

print "Select which file to be converted....\n";
print "1-read1400coils\n";
print "2-read1383coils\n";
print "3-read1088inputs\n";
print "4-MasterControlOut\n";
print "Enter Selection:\n";
$selection=getc;
print "Your selection is $selection\n";

if($selection==1)
{
	open INFILE,"ModOutputs1400WithPVAlias.csv" or die $!;
	open(OUTFILE,"> read1400coilsAlias.substitutions");
	$port="In_Coil00";
	print OUTFILE "# substitutions file for 1400 read bits\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Coils 1 - 1399 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,    DESC,  ALIAS}\n";
}
elsif($selection==2)
{
	open INFILE,"ModOutputs1383WithPVAlias.csv" or die $!;
	open(OUTFILE,"> read1383coilsAlias.substitutions");
	$port="In_Coil01";
	print OUTFILE "# substitutions file for 1383 read bits\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Coils 1400 - 2784 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,    DESC,  ALIAS}\n";
}
elsif($selection==3)
{
        open INFILE,"ModInputsWithPVAlias.csv" or die $!;
	open(OUTFILE,"> read1088inputsAlias.substitutions");
	$port="In_Input00";
	print OUTFILE "# substitutions file for 1088 Inputs\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Inputs 1 - 1088 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,   DESC,   ALIAS}\n";
}
elsif($selection==4)
{
        open INFILE,"ModWritesWithPVAlias.csv" or die $!;
	open(OUTFILE,"> MasterControlOutAlias.substitutions");
	print OUTFILE "# MasterControlOut.substitutions\n";
	print OUTFILE "# writing 256 Coils, in one shot, from Master-Control\n";
	print OUTFILE "\n";
	print OUTFILE "#Waveform array for writing out the Coils\n";
	print OUTFILE "file \"../../db/intarray_out.template\" { pattern\n";
	print OUTFILE "{P,           R,            PORT,                  NELM}\n";
	print OUTFILE "{MOD1:,         CnOutWArray,  MasterControlOut_Word,    368}\n";
	print OUTFILE "}\n\r";
	print OUTFILE "#Binary Out Coils\n";
	print OUTFILE "file \"../../db/MasterControlBOAlias.template\" { pattern\n";
	print OUTFILE "{P,             ZNAM,           ONAM, DESC, ALIAS}\n";
}
else
{
	print "No Selection made...exiting program...\n";
	exit(0);
}

# Read in the file...

my(@lines)=<INFILE>;
my($line);
$lineCt=0;
foreach $line (@lines)
{
	# Skip the first three lines in the csv file
	if($lineCt<3)
	{
		print "Skip this line..\n";
	}
	else
	{
		chomp($line); 		#strip off the trailing newline
		@fields=split(',',$line);
		if($selection<4)
		{
			printf OUTFILE ("{%s,	%s,	%s,	%s,	%s,	NO_ALARM,	NO_ALARM,	\"I/O Intr\",	%s,	%s}\n", $fields[2],$port,$fields[0],$fields[4],$fields[3],$fields[1],$fields[6]);
		}
		else
		{
			printf OUTFILE ("{%s,	%s,	%s,	%s,	%s}\n", $fields[2],$fields[4],$fields[3],$fields[1],$fields[6]);
		}

	}
	$lineCt++;	
}
print OUTFILE "}";
print "\nFile successfully converted into substitution file!\n";
close INFILE;
close OUTFILE;


	
