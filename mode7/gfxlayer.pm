package mode7::gfxlayer;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(new_gfxlayer gfxlayer_set gfxlayer_write gfxlayer_print);
use warnings;
use strict;
use mode7::screen;

sub new_gfxlayer {
	my %layerhash = ();
	my $layer = \%layerhash;

	# All layers have this type set.
	$layer->{type} = 'gfx';

	# Pixel colours:
	# -1  transparent
	#  0  black
	#  1  red, etc.
	for ( my $x = 0; $x < 80; $x++ ) { 
		for ( my $y = 0; $y < 75; $y++ ) { 
			$layer->{px}[$x][$y] = -1;
			}
		}

	return $layer;
	}

sub gfxlayer_set {
	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 

	
	my $px = shift;
	my $py = shift;
	my $cc = shift;
	print "($px, $py) <- $cc\n";
	if ( $cc < 0 || $cc > 7 ) { return; } 

	$layer->{px}[$px][$py] = $cc;
	}

sub gfxlayer_write {
	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 

	my $screen = shift;
	print "(writing)\n";
	my @gfxweights = (1,2,4,8,16,64);

	for ( my $x = 1; $x < 40; $x++ ) { 
		for ( my $y = 0; $y < 25; $y++ ) { 

			my $gx = $x * 2;
			my $gy = $y * 3;
			my $c = ord($screen->{frame}[$x][$y]);				

			for ( my $gox = 0; $gox < 2; $gox++ ) { 
				for ( my $goy = 0; $goy < 3; $goy++ ) { 
					my $weight = $gfxweights[$goy*2+$gox];
					my $px = $x*2 + $gox;
					my $py = $y*3 + $goy;
					my $pc = $layer->{px}[$px][$py];
					my $ca = $weight & $c;

					if ( $pc > -1 ) { 
						print "$px,$py -> $weight & $c = $ca -> $pc\n";
						print "was $pc now $ca\n";
						}

					if ( ( $pc > 0 ) && ( $ca == 0 ) ) {
						print "+ $c\n";
						$c += $weight;
						$screen->{frame}[$x][$y] = chr($c);
						}
					if ( ( $pc == 0 ) && ( $ca > 0 ) ) {
						print "-\n";
						$c -= $weight;
						$screen->{frame}[$x][$y] = chr($c);
						}
					}
				}
			}
		}
	for ( my $y = 0; $y < 25; $y++ ) { 
		$screen->{frame}[0][$y] = chr(151);
		}

	}

sub gfxlayer_print {
	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 

	for ( my $y = 0; $y < 75; $y++ ) { 
		for ( my $x = 0; $x < 80; $x++ ) { 
			my $c = $layer->{px}[$x][$y];
			$c = $c + 0;
			if ( $c < 0 ) { $c = "_"; } 
			if ( $c eq "" ) { $c = " "; } 
			print $c;
			}
		print "\n"; 
		}
	}

1;
