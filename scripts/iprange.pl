#!/usr/bin/perl

# iprange.pl 	A wrapper around iprange.pm module
# INPUT:	ipv4 addr and netmask in CIDR notation
# OUTPUT: 	lowest/highest addrs in input addr's network

BEGIN {push @INC, './perl'}
use strict;
use iprange qw(&iprange);

my %ips = ( cidr => $ARGV[0],
	 low => '',
	 high => '',
);

iprange(\%ips);

if ($ips{low} && $ips{high}) {
    print "$ips{low} $ips{high}\n";
} else {
    print "Error\n";
}



