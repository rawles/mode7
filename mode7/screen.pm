package mode7::screen;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(new_screen screen_advance_cursor screen_set_cursor screen_home_cursor screen_writechar screen_clear screen_trace);
use warnings;
use strict;

sub screen_trace { 
	# Constructs a string fully describing the attributes on every character cell.
	# For debugging.
	my $screen = shift;

	my @colours = ("blk", "red", "grn", "yel", "blu", "mag", "cyn", "wht");
	my @dbtrib_v = ("normal", "double", "reset");
	my @dblpart_v = ("none", "top", "bot");
	my @gftrib_v = ("text", "solid", "text(sep)", "sep");
	my @hgcharsep_v = ("con", "sep");	
	my @hgtrib_v = ("none", "held");	

	my @table = ();
	for ( my $y = 0; $y < 25; $y++ ) { # for each row,
		for ( my $x = 0; $x < 40; $x++ ) { # for each column,
			my $charcode = ord($screen->{frame}[$x][$y]);
			my $echarcode = $charcode; # effective char code
			my $char = "";
			if ( $echarcode > 128 ) { $echarcode -= 128; } 
			if ( $echarcode >= 32 && $echarcode < 127 ) { 
				$char = chr($echarcode);
				}

			my $fgtrib = $colours[$screen->{fgtrib}[$x][$y]];
			my $bgtrib = $colours[$screen->{bgtrib}[$x][$y]];
			my $dbtrib = $dbtrib_v[$screen->{dbtrib}[$x][$y]];
			my $dblpart = $dblpart_v[$screen->{dblpart}[$y]];
			my $gftrib = $gftrib_v[$screen->{gftrib}[$x][$y]];
			my $hgchar = $screen->{hgchar}[$x][$y];
			if ( $hgchar != 0 ) { $hgchar = $hgchar."/"; } else { $hgchar = ""; } 
			my $hgcharsep = $hgcharsep_v[$screen->{hgcharsep}[$x][$y]];
			my $hgtrib = $hgtrib_v[$screen->{hgtrib}[$x][$y]];

			my @line = ();

			push @line, $x;
			push @line, $y;
			push @line, $charcode;
			push @line, $char;
			push @line, ($fgtrib."/".$bgtrib);
			push @line, ($dbtrib."/".$dblpart);
			push @line, $gftrib;
			push @line, ($hgchar.$hgcharsep);
			push @line, $hgtrib;

			push @table, \@line;
			}
		}

	# Format into a table.
	my @headers = ("x", "y", "code", "chr", "colour", "double", "gfx", "hgchar", "hg");
	my @fieldwidth = ();
	foreach my $header ( @headers ) { push @fieldwidth, length($header); } 
	foreach my $lineref ( @table ) { 
		my @line = @{$lineref};
		for ( my $fieldindex = 0; $fieldindex <= $#line; $fieldindex++ ) { 
			if ( length($line[$fieldindex]) > $fieldwidth[$fieldindex] ) { 
				$fieldwidth[$fieldindex] = length($line[$fieldindex]);
				}
			}
		}
	my $trace = "";
	for ( my $fieldindex = 0; $fieldindex <= $#fieldwidth; $fieldindex++ ) { 
		$trace .= substr(
			$headers[$fieldindex].("_"x$fieldwidth[$fieldindex]),
			0, $fieldwidth[$fieldindex]);
		if ( $fieldindex < $#fieldwidth ) { $trace .= " "; } 
		}
	$trace .= "\n";
	foreach my $lineref ( @table ) { 
		my @line = @{$lineref};
		for ( my $fieldindex = 0; $fieldindex <= $#line; $fieldindex++ ) { 
			$trace .= substr(
				$line[$fieldindex].(" "x$fieldwidth[$fieldindex]),
				0, $fieldwidth[$fieldindex]);
			if ( $fieldindex < $#line ) { $trace .= " "; } 
			}
		$trace .= "\n";
		}

	return $trace;
	}

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

	# cursor
	$screen->{cursor}[0] = 0; # left of the screen
	$screen->{cursor}[1] = 0; # top of the screen

	for ( my $x = 0; $x < 240; $x++ ) { 
		for ( my $y = 0; $y < 216; $y++ ) { 

			# Screen pixels are black by default.
			$screen->{gfx}[$x][$y] = 0;

			}
		}
	}

sub screen_advance_cursor {
	my $screen = shift;
	$screen->{cursor}[0]++;
	if ( $screen->{cursor}[0] >= 40 ) {
		$screen->{cursor}[0] = 0;
		$screen->{cursor}[1]++;
		}
	if ( $screen->{cursor}[1] >= 24 ) {
		# we don't support scrolling.
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
