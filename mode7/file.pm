package mode7::file;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(read_frame);
use warnings;
use strict;

sub read_frame { 
	my $screen = shift;
	my $fileName = shift;
	for ( my $y = 0; $y < 24; $y++ ) { 
		for ( my $x = 0; $x < 40; $x++ ) { 
			$screen->{frame}[$x][$y] = " ";
			}
		}
	open(F, $fileName);
	my $lineno = 0;
	while(<F>) { 
		chomp; my $x = $_;
		my $ll = 40; 
		if ( length($x) < $ll ) { $ll = length($x); } 
		for ( my $i = 0; $i < $ll; $i++ ) { 
			$screen->{frame}[$i][$lineno] = substr($x, $i, 1);
			}
		$lineno++;
		}
	close(F);
	}

1;
