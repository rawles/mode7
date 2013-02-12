package mode7::screen;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(new_screen);
use warnings;
use strict;

sub new_screen {
	my %screenhash = ();
	my $screen = \%screenhash;

	# bgtrib[x][y] = the background colour for the character at position (x,y)
	#   1 (red) + 2 (green) + 4 (blue)
	my @bgtrib = (); $screen->{bgtrib} = \@bgtrib;

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

	# frame[x][y] = the character at position (x,y) in the frame.
	my @frame = (); $screen->{frame} = \@frame;

	# gftrib[x][y] = whether the character at position (x,y) is to be rendered
	#   in graphics mode.
	#   0: text mode, but solid graphics if switched back later in the row
	#   1: solid graphics
	#   2: text mode, but separated graphics if switched back later in the row
	#   3: separated graphics
	my @gftrib = (); $screen->{gftrib} = \@gftrib;

	# gfx[x][y] = the colour of pixel (x,y) in the output graphic.
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

	for ( my $y = 0; $y < 25; $y++ ) { # for each row,

		# Initially, no double-height statuses are defined.
		$screen->{dblpart}[$y] = 0;

		for ( my $x = 0; $x < 40; $x++ ) { # for each column,

			# Characters have a black background by default.
			$screen->{bgtrib}[$x][$y] = 0;

			# Characters are normal height by default.
			$screen->{dbtrib}[$x][$y] = 0;

			# Initialise the frame with spaces.
			$screen->{frame}[$x][$y] = " ";

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

	for ( my $x = 0; $x < 240; $x++ ) { 
		for ( my $y = 0; $y < 216; $y++ ) { 

			# Screen pixels are black by default.
			$screen->{gfx}[$x][$y] = 0;

			}
		}
	
	return $screen;
	}

1;
