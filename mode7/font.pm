package mode7::font;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(read_font font_has);
use warnings;
use strict;

sub read_font { 
	my $fontFile = shift;
	my @font = ();
	open(F, $fontFile);
	binmode F, ":utf8";
	while(<F>) { chomp; my $x = $_;
		my @p = split(/,/, $x);
		for ( my $i = 0; $i < 9; $i++ ) { 
			$font[$p[0]][$i] = $p[$i+1];
			}
		}
	return @font;
	}

sub font_has { # does the font contain this code?
	my $fonthash = shift;
	my $cc = shift;
	my @font = @{$fonthash};

	if ( $#{$font[$cc]} == 8 ) { return 1; } 
	return 0;
	}

1;
