package mode7::render;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(render);
use warnings;
use strict;
use mode7::draw;

# Call render at any time to update the graphics part of the screen.
sub render { 
	my $screen = shift;
	my $fontref = shift;

	my $allow_80 = 0; # allow black text (heresy)
	my $allow_90 = 1; # allow black backgrounds

	for ( my $cy = 0; $cy < 24; $cy++ ) { 
		for ( my $cx = 0; $cx < 40; $cx++ ) { 
			my $framechar = " ";
			if ( defined $screen->{frame}[$cx][$cy] ) {
				$framechar = $screen->{frame}[$cx][$cy];
				} 

			#if ( $cy > 0 && $screen->{dbtrib}[$cx][$cy-1] == 1
			##	&& $screen->{dblpart}[$cy-1] == 1 ) { 
			if ( $cy > 0 && $screen->{dblpart}[$cy-1] == 1 ) { 
				$framechar = $screen->{frame}[$cx][$cy-1];
				}

			my $cc = ord($framechar);

			if ( $allow_80 != 1 && $cc == 128 ) { 
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( ( $allow_80 == 1 && $cc == 128 )
			||   ( $cc >= 129 && $cc <= 135 ) ) { # Alpha
				my $newcolour = $cc - 128;
				for ( my $i = $cx + 1; $i < 40; $i++ ) { 
					$screen->{fgtrib}[$i][$cy] = $newcolour;
					$screen->{gftrib}[$i][$cy] &= 2; # drop LSB
					# 0->0 1->0 2->2 3->2
					}
				cc($screen,$fontref,$cx,$cy);
				next; 
				}

			#140 = normal height, should also reset held graphics
			if ( $cc == 140 ) { 
				for ( my $i = $cx; $i < 40; $i++ ) { 
					$screen->{dbtrib}[$i][$cy] = 2;
					}
				# we dont mess with which part it is in case
				# user switches back 
				cc($screen,$fontref,$cx,$cy);
				next;
				}

			if ( $cc == 141 ) { 
				for ( my $i = $cx; $i < 40; $i++ ) { 
					$screen->{dbtrib}[$i][$cy] = 1;
					}
				if ( $screen->{dblpart}[$cy] == 0 ) { 
					$screen->{dblpart}[$cy] = 1; 
					$screen->{dblpart}[$cy+1] = 2; 
					}
				# reset held graphics
				for ( my $i = $cx; $i < 40; $i++ ) {
					$screen->{hgtrib}[$i][$cy] = 0;
					$screen->{hgchar}[$i][$cy] = 32;
					$screen->{hgcharsep}[$i][$cy] = 0;
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 142 ) { # "SO"
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 143 ) { # "SI"
				cc($screen,$fontref,$cx,$cy);
				next;
				}

			if ( $allow_90 != 1 && $cc == 144 ) { 
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( ( $allow_90 && $cc == 144 ) 
			||   ( $cc >= 145 && $cc <= 151 ) ) { # Graphics
				my $newcolour = $cc - 144;

				# If a graphics mode already established, use
				# that. If not, use mode 1 (continuous)

				my $newgfxmode = 1;
				if ( $screen->{gftrib}[$cx][$cy] >= 2 ) { $newgfxmode = 3; } 
				# 0->1 1->1 2->3 3->3

				for ( my $i = $cx+1; $i < 40; $i++ ) { 
					$screen->{fgtrib}[$i][$cy] = $newcolour;
					$screen->{gftrib}[$i][$cy] = $newgfxmode;
					}
				cc($screen,$fontref,$cx,$cy);
				next; 
				}
			if ( $cc == 152 ) { # conceal
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 153 ) { # contiguous graphics
				for ( my $i = $cx + 1; $i < 40; $i++ ) { 
					$screen->{gftrib}[$i][$cy] = $screen->{gftrib}[$i][$cy] % 2; # drop MSB 
					# 0->0 1->1 2->0 3->1
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 154 ) { # separated graphics
				for ( my $i = $cx + 1; $i < 40; $i++ ) { 
					$screen->{gftrib}[$i][$cy] = ( $screen->{gftrib}[$i][$cy] % 2 ) + 2; 
					# 0->2  1->3  2->2  3->3
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 156 ) { # Black background
				for ( my $i = $cx; $i < 40; $i++ ) { 
					$screen->{bgtrib}[$i][$cy] = 0;
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 157 ) { # New background
				my $newcolour = $screen->{fgtrib}[$cx][$cy];
				for ( my $i = $cx; $i < 40; $i++ ) { 
					$screen->{bgtrib}[$i][$cy] = $newcolour;
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 158 ) { # held graphics on
				for ( my $i = $cx; $i < 40; $i++ ) {
					$screen->{hgtrib}[$i][$cy] = 1;
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}
			if ( $cc == 159 ) { # held graphics off
				# reset held graphics
				for ( my $i = $cx + 1; $i < 40; $i++ ) {
					$screen->{hgtrib}[$i][$cy] = 0;
					#$screen->{hgchar}[$i][$cy] = 0;
					#$screen->{hgcharsep}[$i][$cy] = 0;
					}
				cc($screen,$fontref,$cx,$cy);
				next;
				}

			my $gfxchar = 0; # is this to be rendered as a graphics character?
			if ( $screen->{gftrib}[$cx][$cy] % 2 > 0 ) { 
				if ( $cc >= 32 && $cc <= 63 ) { $gfxchar = 1; }
				if ( $cc >= 96 && $cc <= 127 ) { $gfxchar = 1; }
				if ( $cc >= 128+32 && $cc <= 128+63 ) { $gfxchar = 1; }
				if ( $cc >= 128+96 && $cc <= 128+127 ) { $gfxchar = 1; }
				}

			# if it is, we need to propagate it along the rest of the line to
			# be used for held graphics, if required.
			if ( $gfxchar == 1 ) { 
				my $newsep = int($screen->{gftrib}[$cx][$cy]/2);
				# 0->0 1->0 2->1 3->1
				for ( my $i = $cx; $i < 40; $i++ ) { 
					$screen->{hgchar}[$i][$cy] = $cc;
					$screen->{hgcharsep}[$i][$cy] = $newsep;
					}
				}

			drawchar($screen,$fontref,$cx, $cy, $cc, $gfxchar);
			}
		}
	}

1;
