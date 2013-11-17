package mode7::screen;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(new_screen screen_advance_cursor screen_set_cursor screen_home_cursor screen_writechar screen_clear screen_flash_invariant);
use warnings;
use strict;

sub new_screen {
	my %screenhash = ();
	my $screen = \%screenhash;

	# bgtrib[x][y] = the background colour for the character at position (x,y)
	#   1 (red) + 2 (green) + 4 (blue)
	my @bgtrib = (); $screen->{bgtrib} = \@bgtrib;

	# cotrib[x][y] = whether the character at position (x,y) is concealed
	#   0: not concealed
	#   1: concealed
	my @cotrib = (); $screen->{cotrib} = \@cotrib;

	# dbtrib[x][y] = whether the character at position (x,y) is to be rendered
	#   as double height.
	#   0: normal height
	#   1: double height
	#   2: normal height after having asserted that with char 140
	my @dbtrib = (); $screen->{dbtrib} = \@dbtrib;

	# dblpart[y] = the double-height status of line y.
	#   0: no double-height status yet assigned to line y.
	#   1: line y is the top line of a double-height line pair.
	#   2: line y is the bottom line of a double-height line pair.
	my @dblpart = (); $screen->{dblpart} = \@dblpart;

	# fgtrib[x][y] = the foreground colour for the character at position (x,y)
	#   1 (red) + 2 (green) + 4 (blue)
	my @fgtrib = (); $screen->{fgtrib} = \@fgtrib;

	# fltrib[x][y] = whether the character at position (x,y) is flashing
	#   0: steady (no flashing)
	#   1: flashing
	my @fltrib = (); $screen->{fltrib} = \@fltrib;

	# frame[x][y] = the character at position (x,y) in the frame.
	my @frame = (); $screen->{frame} = \@frame;

	# gftrib[x][y] = whether the character at position (x,y) is to be rendered
	#   in graphics mode.
	#   0: text mode, but solid graphics if switched back later in the row
	#   1: solid graphics
	#   2: text mode, but separated graphics if switched back later in the row
	#   3: separated graphics
	my @gftrib = (); $screen->{gftrib} = \@gftrib;

	# gfx[v][x][y] = the colour of pixel (x,y) in the output graphic. Versions
	#   of the screen exist for each flash phase (and maybe for reveal mode
	#   in a future version. v=0 means the off phase, v=1 means the on phase.
	#   1 (red) + 2 (green) + 4 (blue)
	# TODO: make this stucture a bitmap to save memory.
	my @gfx = (); $screen->{gfx} = \@gfx;

	# hgchar[x][y] = the character printed when a control character is used.
	#   Used for held graphics effects. This is an integer value, representing
	#   the index of the character in the character map.
	my @hgchar = (); $screen->{hgchar} = \@hgchar;

	# hgcharsep[x][y] = is the held graphics character at character position
	#   (x,y) separated or not?
	#   0: continuous
	#   1: separated
	my @hgcharsep = (); $screen->{hgcharsep} = \@hgcharsep;

	# hgtrib[x][y] = whether held graphics are being used for character (x,y)
	#   0: no held graphics
	#   1: held graphics
	my @hgtrib = (); $screen->{hgtrib} = \@hgtrib;

	screen_clear($screen);
	return $screen;
	}

sub screen_clear {
	my $screen = shift;
	for ( my $y = 0; $y < 25; $y++ ) { # for each row,

		# Initially, no double-height statuses are defined.
		$screen->{dblpart}[$y] = 0;

		for ( my $x = 0; $x < 40; $x++ ) { # for each column,

			# Characters have a black background by default.
			$screen->{bgtrib}[$x][$y] = 0;

			# Characters are not concealed by default.
			$screen->{cotrib}[$x][$y] = 0;

			# Characters are normal height by default.
			$screen->{dbtrib}[$x][$y] = 0;

			# Initialise the frame with spaces.
			$screen->{frame}[$x][$y] = " ";

			# Characters are steady by default.
			$screen->{fltrib}[$x][$y] = 0;

			# Characters are white by default.
			$screen->{fgtrib}[$x][$y] = 7;

			# Characters are text by default, and would be solid if a later
			#   character switched them into graphics mode.
			$screen->{gftrib}[$x][$y] = 0;

			# The held graphics character is a space by default.
			$screen->{hgchar}[$x][$y] = 32;

			# The held graphics character is continuous by default.
			$screen->{hgcharsep}[$x][$y] = 0;

			# Graphics are released (not held) by default.
			$screen->{hgtrib}[$x][$y] = 0;
			}
		}

	# cursor
	$screen->{cursor}[0] = 0; # left of the screen
	$screen->{cursor}[1] = 0; # top of the screen

	for ( my $x = 0; $x < 240; $x++ ) { 
		for ( my $y = 0; $y < 225; $y++ ) { 

			# Screen pixels are black by default.
			$screen->{gfx}[0][$x][$y] = 0;
			$screen->{gfx}[1][$x][$y] = 0;

			}
		}
	}

# Are the two versions of the screen the same pixel-wise?
sub screen_flash_invariant { 
	my $screen = shift;
	for ( my $x = 0; $x < 240; $x++ ) { 
		for ( my $y = 0; $y < 225; $y++ ) { 
			if ( $screen->{gfx}[0][$x][$y] != $screen->{gfx}[1][$x][$y] ) { return 0; } 
			}
		}
	return 1;
	}

sub screen_advance_cursor {
	my $screen = shift;
	$screen->{cursor}[0]++;
	if ( $screen->{cursor}[0] >= 40 ) {
		$screen->{cursor}[0] = 0;
		$screen->{cursor}[1]++;
		}
	if ( $screen->{cursor}[1] >= 25 ) {
		# we don't support scrolling, so wrap to the first line.
		$screen->{cursor}[1] = 0;
		}
	}

sub screen_set_cursor {
	my $screen = shift;
	my $x = shift;
	my $y = shift;
	$screen->{cursor}[0] = $x;
	$screen->{cursor}[1] = $y;
	}

sub screen_home_cursor {
	my $screen = shift;
	$screen->{cursor}[0] = 0;
	$screen->{cursor}[1] = 0;
	}

sub screen_writechar {
	my $screen = shift;
	my $c = shift;
	my $cx = $screen->{cursor}[0];
	my $cy = $screen->{cursor}[1];
	$screen->{frame}[$cx][$cy] = $c;
	screen_advance_cursor($screen);
	}

1;
