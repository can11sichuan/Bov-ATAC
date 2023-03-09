#!/usr/bin/perl
use strict;
use warnings;
my $inputdir = shift or die "Must supply input filename\n";
opendir DH,$inputdir or die "Unable to open $inputdir\n";
my ($dir,@all,%hash,%hash2,$key,$key1,$key2);
while ( $dir = readdir DH){
	#print "$dir\n";
	open IN, "<$inputdir/$dir";
	while (<IN>){
	chomp;
	@all=split(/\t/,$_);
	$hash{$all[3]}{$all[10]}=$all[6];
	$hash2{$all[10]}=0;
	}
	close IN;
}

closedir DH;

foreach $key (sort keys %hash2){
	print "\t$key";
}

foreach $key1 (keys %hash) {
	print "\n$key1";
	foreach $key2 (sort keys %hash2){
		if ( exists $hash{$key1}{$key2} ){
		print "\t$hash{$key1}{$key2}";
		}else{
		print "\t0";
		}
	}
}
print "\n";
