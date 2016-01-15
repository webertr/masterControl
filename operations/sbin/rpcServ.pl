#!/usr/bin/perl -w

use RPC::XML;
use RPC::XML::Server;
use Socket;
use Sys::Hostname;

# will set  'host' to be ip address of  hostname unless you want to define 
# otherwise
my $name = hostname();
my $addr = inet_ntoa(scalar(gethostbyname($name)) || 'localhost');
my $host = $addr unless ! $addr;
# ... otherwise...
#my $host = "192.168.0.4";

my $port = "8000";
my $daemon = RPC::XML::Server->new(host => $host, port => $port);
#
#
# add methods for each function/sub you wish to make available
#
$daemon->add_method({
		name => 'iocUsage',
		signature => ['string'],
		code => \&getUsage
});
$daemon->add_method({
		name => 'iocStop',
		signature => ['string'],
		code => \&procservStop
});
$daemon->add_method({
		name => 'iocStart',
		signature => ['string'],
		code => \&procservStart
});
$daemon->add_method({
		name => 'iocRestart',
		signature => ['string'],
		code => \&procservRestart
});
$daemon->server_loop();
#
######################################################################
# functions/subs   that can be called via the rpc server's methods
#
sub getUsage {
	my $usage = ` /usr/local/cnts/epics/operations/etc/init.d/psi 2>&1 `;
	return $usage;
}
sub procservStop {
	my $retval = ` /usr/local/cnts/epics/operations/etc/init.d/psi quietstop 2>&1 `;
	return $retval;
}
sub procservStart {
	my $retval = ` /usr/local/cnts/epics/operations/etc/init.d/psi quietstart 2>&1 `;
	return $retval;
}
sub procservRestart {
	my $retval = ` /usr/local/cnts/epics/operations/etc/init.d/psi quietrestart 2>&1 `;
	return $retval;
}
