package mode7::draw;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(cc drawchar);
use mode7::font;
use mode7::config;
use warnings;
use strict;

sub cc { # Asserts that a control character is here
	my $screen = shift;
	my $fontref = shift;
	my $reveal = shift;  # are we in a reveal state?
	                     # 0 concealed text hidden, 1 concealed text shown
	my $cx = shift;
	my $cy = shift;
	for ( my $y = 0; $y < 9; $y++ ) { 
		for ( my $x = 0; $x < 6; $x++ ) { 
			my $px = $cx * 6 + $x;
			my $py = $cy * 9 + $y;
			my $pc = 0;
			if ( $screen->{bgtrib}[$cx][$cy] > 0 && $pc == 0 ) { 
				$pc = $screen->{bgtrib}[$cx][$cy];
				}
			$screen->{gfx}[0][$px][$py] = $pc;
			$screen->{gfx}[1][$px][$py] = $pc;
			}
		}
	if ( $screen->{hgtrib}[$cx][$cy] == 1 ) { # hg would be shown here
		my $passedhgchar = $screen->{hgchar}[$cx][$cy];
		if ( $passedhgchar == 0 ) { $passedhgchar = 32; } 
		drawchar($screen,$fontref,$reveal,$cx,$cy,$passedhgchar,
			2+$screen->{hgcharsep}[$cx][$cy]);
		}
	}

sub drawchar { 
	my $screen = shift;
	my $fontref = shift;
	my $reveal = shift;
	my $cx = shift;
	my $cy = shift;
	my $cc = shift;
	my $gfxchar = shift;

	# Once for each phase.
	drawchar_phase($screen, $fontref, 0, $reveal, $cx, $cy, $cc, $gfxchar);
	drawchar_phase($screen, $fontref, 1, $reveal, $cx, $cy, $cc, $gfxchar);
	}

sub drawchar_phase {
	my $screen = shift;
	my $fontref = shift; my @font = @{$fontref};
	my $phase = shift;   # the flash phase. 
	                     # 0 flash chars off, 1 flash chars on.
	my $reveal = shift;  # are we in a reveal state?
	                     # 0 concealed text hidden, 1 concealed text shown
	my $cx = shift;      # the x-position
	my $cy = shift;      # the y-position
	my $cc = shift;      # the character code at this position
	my $gfxchar = shift; # 0 (text mode), 1 (graphic mode) 
	                     # 2 (graphic mode forced to continuous)
                             # 3 (graphic mode forced to separated)
	                     # We need this forced mode for held graphics.

	my @gfxweights = (1,2,4,8,16,64);
	                     # the weights of each graphic cell

	# BBC Microcomputers use 0, Prestel and Teletext use 1.
	my $blank_normal_l2 = 0; # line two when switching back isnt shown
	if ( config_get("emulation") eq "viewdata" ) { $blank_normal_l2 = 1; }
	if ( config_get("emulation") eq "micro" ) { $blank_normal_l2 = 0; }

	# Writes into @gfx instead of returning data.

	my $useblank = 0;    # Blanking of characters where they are
	                     # the second row of a double-height line.

	if ( 	$blank_normal_l2 == 1
	&&	( $screen->{dbtrib}[$cx][$cy] == 0
		|| $screen->{dbtrib}[$cx][$cy] == 2 ) 
	&&	$screen->{dblpart}[$cy] == 2 ) { 
		$useblank = 1;
		}

	for ( my $y = 0; $y < 9; $y++ ) { 
		for ( my $x = 0; $x < 6; $x++ ) { 
			my $px = $cx * 6 + $x; # absolute x-position
			my $py = $cy * 9 + $y; # absolute y-position
			my $pc = 0;            # pixel colour
			if ( $gfxchar == 0 ) { # text mode

				if ( $cc >= 128 ) { $cc -= 128; } # strip top bit
				if ( font_has(\@font, $cc) == 1 ) { 
					$pc = $font[$cc][$y] & 1<<5-$x;
					} else { 
					$pc = 0;
					}
				if ( $pc > 0 ) { $pc = 7; }       # for later &-ing

				} else {       # graphic mode, solid or sep
				my $gx = int($x/3);
				my $gy = int($y/3);
				my $gi = $gfxweights[$gy*2+$gx];
				my $gt = $screen->{gftrib}[$cx][$cy];

				# apply the override
				if ( $gfxchar == 2 ) { $gt = 1; } 
				if ( $gfxchar == 3 ) { $gt = 3; } 

				if ( $cc >= 128 ) { 
					$pc = ( $cc - 160 ) & $gi;
					} else {
					$pc = ( $cc - 32 ) & $gi;
					}
				if ( $pc > 0 ) { $pc = 7; } 

				# If seperated, blank out the necessary lines.
				if ( $gt == 3 && $x == 0 ) { $pc = 0; } 
				if ( $gt == 3 && $x == 3 ) { $pc = 0; } 
				if ( $gt == 3 && $y == 0 ) { $pc = 0; } 
				if ( $gt == 3 && $y == 3 ) { $pc = 0; } 
				if ( $gt == 3 && $y == 6 ) { $pc = 0; } 
				}

			# Dump the above if it's one of the blanked characters.
			if ( $useblank == 1 ) { $pc = 0; }

			# Dump the above if we're on flash phase 0 and this is in flash mode.
			if ( ( $phase == 0 ) && ( $screen->{fltrib}[$cx][$cy] == 1 ) ) { $pc = 0; }

			# Dump the above if we're not revealed and this is in reveal mode
			if ( ( $reveal == 0 ) && ( $screen->{cotrib}[$cx][$cy] == 1 ) ) { $pc = 0; }

			# Colour the character with the correct foreground attributes
			if ( $screen->{fgtrib}[$cx][$cy] > 0 ) { 
				$pc &= $screen->{fgtrib}[$cx][$cy];
				}

			# Remaining pixels are now background.
			if ( $screen->{bgtrib}[$cx][$cy] > 0 && $pc == 0 ){ 
				$pc = $screen->{bgtrib}[$cx][$cy];
				}

			# Write it into the graphical representation.
			$screen->{gfx}[$phase][$px][$py] = $pc;
			}
		}

	if ( $screen->{dbtrib}[$cx][$cy] == 1 ) {
		# This is a double-height character, either the top or the bottom 
		# half. We copy a half of the cell back into itself to form the
		# double-height letter section. 

		if ( $screen->{dblpart}[$cy] == 1 ) { 
			# Copying from halfway up to the bottom, and moving up.
			for ( my $y = 8; $y >= 0; $y-- ) { 
				my $copyfrom = int($y/2); # rows 0..4

				# 8 7 6 5 4 3 2 1 0 destination
				# ^ ^ ^ ^ ^ ^ ^ ^ ^
				# 4 3 3 2 2 1 1 0 0 source

				for ( my $x = 0; $x < 6; $x++ ) { 
					my $px = $cx * 6 + $x;
					my $py = $cy * 9 + $y;
					my $pyf = $cy * 9 + $copyfrom;
					$screen->{gfx}[$phase][$px][$py] = $screen->{gfx}[$phase][$px][$pyf];
					}
				}
			}
		if ( $screen->{dblpart}[$cy] == 2 ) { 
			# Copying from halfway down to the bottom, and moving down.
			for ( my $y = 0; $y < 9; $y++ ) { 
				my $copyfrom = int(($y+1)/2) + 4; # rows 4..8

				# 0 1 2 3 4 5 6 7 8  destination
				# ^ ^ ^ ^ ^ ^ ^ ^ ^
				# 4 5 5 6 6 7 7 8 8  source

				for ( my $x = 0; $x < 6; $x++ ) { 
					my $px = $cx * 6 + $x;
					my $py = $cy * 9 + $y;
					my $pyf = $cy * 9 + $copyfrom;
					$screen->{gfx}[$phase][$px][$py] = $screen->{gfx}[$phase][$px][$pyf];
					}
				}
			}
		}

	}

1;
