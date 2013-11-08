package mode7::gfxlayer;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(new_gfxlayer gfxlayer_set gfxlayer_write gfxlayer_print);
use warnings;
use strict;
use mode7::screen;

# This module is a work in progress.

# It represents an ideal teletext graphics layer, where each pixel can 
# be assigned a colour independent of the others. The idea is that some
# optimising routine can turn this into something which works for the 
# teletext standard (as far as possible). A pixel can be transparent.

sub new_gfxlayer {
	my %layerhash = ();
	my $layer = \%layerhash;

	# All layers have this value set, to indicate its type.
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
	# Assign a colour to a pixel.

	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 
	
	my $px = shift;
	my $py = shift;
	my $cc = shift;
	if ( $cc < 0 || $cc > 7 ) { return; } 

	$layer->{px}[$px][$py] = $cc;
	}

sub gfxlayer_write {
	# Write this grapics layer into the screen supplied.

	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 

	my $screen = shift;
	my @gfxweights = (1, 2, 4, 8, 16, 64);

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

					# The character code restricted to this weight.
					my $ca = $weight & $c;

					if ( ( $pc > 0 ) && ( $ca == 0 ) ) {
						# This is non-black, so we set the sub-cell
						$c += $weight;
						$screen->{frame}[$x][$y] = chr($c);
						}
					if ( ( $pc == 0 ) && ( $ca > 0 ) ) {
						# This is black, so we unset the sub-cell
						$c -= $weight;
						$screen->{frame}[$x][$y] = chr($c);
						}
					}
				}
			}
		}

	# Put a white graphic character in for now.
	for ( my $y = 0; $y < 25; $y++ ) { 
		$screen->{frame}[0][$y] = chr(151);
		}

	}

sub gfxlayer_print {
	# A convenience method for debugging.
	
	my $layer = shift;
	if ( $layer->{type} ne 'gfx' ) { return; } 

	for ( my $y = 0; $y < 75; $y++ ) { 
		for ( my $x = 0; $x < 80; $x++ ) { 
			my $c = $layer->{px}[$x][$y];
			$c = $c + 0;
			if ( $c < 0 ) { $c = "_"; }    # _ means transparent
			if ( $c eq "" ) { $c = " "; }  # space means empty
			print $c;
			}
		print "\n"; 
		}
	}

1;
