#!/usr/bin/perl 
# echo "|/home/crhodes/scripts/check_core.pl %t %p %s %u %g" > /proc/sys/kernel/core_pattern
use Devel::GDB;
use strict;
use warnings;
 
my $t = $ARGV[0];
my $p = $ARGV[1];
my $s = $ARGV[2];
my $u = $ARGV[3];
my $g = $ARGV[4];
 
my $corefile = do { local $/; <STDIN> };
my $core_file = "/var/crash/core.$t.$p.$s.$u.$g";
 
open (COREFILE, ">>$core_file");
print COREFILE $corefile;
close COREFILE;
 
my $exec_info =  `gdb --batch -c $core_file -x quit`;
$exec_info =~ m/Core was generated by `(.+)'/;
(my $exec_path) = split(/\s/,$1,0);
 
my $gdb_params = "-q -e $exec_path -c $core_file";
my $gdb = new Devel::GDB( '-params' => $gdb_params, '-use-tty' => "/dev/pts/ptmx" );
 
my $where = $gdb->get("where");
my $bt = $gdb->get("thread apply all bt");
my $info = $gdb->get("info threads");
$gdb->end;
 
open(BT,">>/tmp/btlog");
print BT "$core_file\n";
print BT "$where\n";
print BT "$bt\n";
print BT "$info\n";
close BT;