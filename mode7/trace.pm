package mode7::trace;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(trace_screen trace_tribs);
use warnings;
use strict;

sub trace_tribs { 
	# Constructs a string describing the attributes on every character cell which doesn't
	# already appear in trace_screen. I'm moving to trace_screen as I prefer debugging with
	# it.
	my $screen = shift;

	my @dbtrib_v = ("normal height (0)", "double height (1)", "normal height, reset (2)");
	my @dblpart_v = ("none (0)", "top half (1)", "bottom half (2)");
	my @hgcharsep_v = ("contiguous (0)", "separated (1)");	
	my @hgtrib_v = ("none (0)", "held (1)");	

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

			my $dbtrib = $dbtrib_v[$screen->{dbtrib}[$x][$y]];
			my $dblpart = $dblpart_v[$screen->{dblpart}[$y]];

			my $hgchar = $screen->{hgchar}[$x][$y];
			#if ( $hgchar != 0 ) { $hgchar = $hgchar."/"; } else { $hgchar = ""; } 
			my $hgcharsep = $hgcharsep_v[$screen->{hgcharsep}[$x][$y]];
			my $hgtrib = $hgtrib_v[$screen->{hgtrib}[$x][$y]];

			my @line = ();

			push @line, $x;
			push @line, $y;
			push @line, ($dbtrib.", ".$dblpart);
			push @line, $hgtrib;
			push @line, ($hgchar.", ".$hgcharsep);

			push @table, \@line;
			}
		}

	# Format into a table.
	my @headers = ("x", "y", "double height", "held graphics", "held graphics character");
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

	$trace .= "\n";
	}

sub trace_screen { 

	my $screen = shift;
	my $trace = ""; 

	my @colcodes = ("K", "R", "G", "Y", "B", "M", "C", "W");
	my @gfxcodes = ("Tx", "So", "Ts", "Sp");

	for ( my $y = 0; $y < 216; $y++ ) { 
		for ( my $x = 0; $x < 240; $x++ ) { 
			my $c = $screen->{gfx}[$x][$y];
			if ( $c < 1 || $c > 7 ) { $c = "."; } 
			$trace .= $c;
			if ( $x % 6 == 5 && $x < 239 ) { $trace .= " "; } 
			}
		$trace .= "\n";
		if ( $y % 9 == 8 ) {
			my $ty = int($y/9);
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				$trace .= substr("      $tx,$ty", -6);
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $charcode = ord($screen->{frame}[$tx][$ty]);
				my $echarcode = $charcode; # effective char code
				$charcode = sprintf("0x%X", $charcode);
				my $char = "";
				if ( $echarcode > 128 ) { $echarcode -= 128; } 
				if ( $echarcode >= 32 && $echarcode < 127 ) { 
					$char = chr($echarcode);
					}
				$trace .= substr("      $char $charcode", -6);
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $colgfx = "";
				$colgfx .= uc($colcodes[$screen->{fgtrib}[$tx][$ty]]);
				$colgfx .= "/";
				$colgfx .= lc($colcodes[$screen->{bgtrib}[$tx][$ty]]);
				$colgfx .= " ";
				$colgfx .= $gfxcodes[$screen->{gftrib}[$tx][$ty]];
				$trace .= $colgfx;
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n\n";
			} 
		}


	return $trace;
	}

1;
